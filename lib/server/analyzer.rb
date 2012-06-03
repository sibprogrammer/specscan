require 'server/abstract'

module Server; end

class Server::Analyzer < Server::Abstract

  MIN_METERS_FOR_MOVEMENT_START = 3
  MAX_METERS_FOR_FALSE_MOVEMENT_START = 1000
  MIN_SECONDS_FOR_PARKING_WITH_ENGINE_ON = 120
  MIN_SPEED_KM = 3

  def initialize
    @log_file = "#{Rails.root}/log/analyzer.log"
  end

  def start
    loop do
      Vehicle.with_imei.each do |vehicle|
        update_movements(vehicle)
        update_reports(vehicle)
      end
      sleep(5.minutes.to_i)
    end
  end

  private

    def update_movements(vehicle)
      logger.debug "Updating tracks for vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

      last_movement = Movement.where(:imei => vehicle.imei).sort(:to_timestamp).last

      if !last_movement
        first_way_point = WayPoint.where(:imei => vehicle.imei, :coors_valid => true).sort(:timestamp).first
        return if !first_way_point
        last_movement = Movement.new({
          :imei => vehicle.imei,
          :from_timestamp => first_way_point.timestamp,
          :to_timestamp => first_way_point.timestamp,
          :parking => true
        })
        last_movement.save
      end

      conditions = {
        :imei => vehicle.imei,
        :timestamp => { :$gt => last_movement.to_timestamp },
      }

      movements = [last_movement]
      prev_way_point = WayPoint.where(:imei => vehicle.imei, :timestamp.lt => last_movement.to_timestamp).sort(:timestamp.desc).first

      WayPoint.where(conditions).sort(:timestamp).each do |way_point|
        update_fuel_changes(way_point, prev_way_point, vehicle, last_movement) if prev_way_point
        prev_way_point = way_point
        next unless way_point.coors_valid
        last_movement = analyze_way_point(way_point, vehicle.imei, last_movement)
        movements << last_movement if last_movement.id.to_s != movements.last.id.to_s
      end

      movements.each{ |movement| update_distance(movement) }
    end

    def update_fuel_changes(way_point, prev_way_point, vehicle, last_movement)
      fuel_diff = prev_way_point.fms_fuel.to_i - way_point.fms_fuel.to_i
      return if fuel_diff.abs < 0.01

      tank_size = vehicle.fuel_tank
      fuel_ammount = (tank_size / 100) * fuel_diff.abs

      if 1 == fuel_diff
        last_movement.fuel_used = (last_movement.fuel_used.to_i + fuel_ammount).to_f
        last_movement.save
      else
        prev_fuel_change = FuelChange.where(:imei => vehicle.imei, :to_timestamp.lt => way_point.timestamp).sort(:to_timestamp.desc).first
        multiplier = (fuel_diff > 1) ? -1 : 1

        if prev_fuel_change and prev_fuel_change.multiplier == multiplier and (way_point.timestamp - prev_fuel_change.to_timestamp) < 60
          prev_fuel_change.to_timestamp = way_point.timestamp
          prev_fuel_change.amount += fuel_ammount.to_f
          prev_fuel_change.save
        else
          FuelChange.create({
            :imei => vehicle.imei,
            :multiplier => multiplier,
            :amount => fuel_ammount.to_f,
            :from_timestamp => way_point.timestamp,
            :to_timestamp => way_point.timestamp,
            :way_point => way_point,
          })
        end

        logger.debug "Fuel ammount changed: #{fuel_ammount*multiplier}"
      end
    end

    def analyze_way_point(way_point, imei, last_movement)
      if (way_point.timestamp - last_movement.to_timestamp) > 10.minutes.to_i
        logger.debug "Large timespan between points: #{way_point.timestamp - last_movement.to_timestamp} sec."
        if last_movement.parking
          last_movement.to_timestamp = way_point.timestamp
        else
          last_movement = create_parking(imei, last_movement, way_point)
        end

        last_movement.save
        return last_movement
      end

      if last_movement.parking
        # if last was a parking
        if !way_point.engine_on and !way_point.sens_moving
          last_movement.to_timestamp = way_point.timestamp
        else
          distance = way_point.distance(WayPoint.get_by_timestamp(last_movement.from_timestamp, imei))
          if distance > MIN_METERS_FOR_MOVEMENT_START and way_point.speed > MIN_SPEED_KM
            last_movement.save
            last_movement = create_movement(imei, last_movement, way_point)
          else
            last_movement.to_timestamp = way_point.timestamp
          end
        end

        last_movement.save
      else
        # if last was a movement
        if !way_point.engine_on and !way_point.sens_moving
          prev_way_point = WayPoint.nearest_point(way_point.timestamp, imei)

          if prev_way_point and (prev_way_point.engine_on or prev_way_point.sens_moving) and prev_way_point.timestamp > last_movement.from_timestamp
            last_movement.to_timestamp = way_point.timestamp
          else
            prev_way_point = WayPoint.find_closest_older(way_point, last_movement)

            if prev_way_point
              last_movement.to_timestamp = prev_way_point.timestamp
              last_movement.save
            end

            last_movement = create_parking(imei, last_movement, way_point)
          end
        else
          prev_way_point = WayPoint.nearest_point(way_point.timestamp - MIN_SECONDS_FOR_PARKING_WITH_ENGINE_ON, imei)
          if prev_way_point and prev_way_point.timestamp > last_movement.from_timestamp and prev_way_point.distance(way_point) < MIN_METERS_FOR_MOVEMENT_START
            last_movement.to_timestamp = prev_way_point.timestamp
            last_movement.save
            last_movement = create_parking(imei, last_movement, way_point)
          else
            last_movement.to_timestamp = way_point.timestamp
          end
        end

        last_movement.save
      end

      last_movement
    end

    def create_parking(imei, last_movement, way_point)
      logger.debug "Parking started from: #{last_movement.from_timestamp}, #{Time.at(last_movement.from_timestamp)}"

      Movement.new({
        :imei => imei,
        :from_timestamp => last_movement.to_timestamp,
        :to_timestamp => way_point.timestamp,
        :parking => true
      })
    end

    def create_movement(imei, last_movement, way_point)
      logger.debug "Movement started from: #{last_movement.from_timestamp}, #{Time.at(last_movement.from_timestamp)}"

      Movement.new({
        :imei => imei,
        :from_timestamp => last_movement.to_timestamp,
        :to_timestamp => way_point.timestamp,
        :parking => false
      })
    end

    def update_reports(vehicle)
      logger.debug "Updating reports for vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

      last_report = Report.where(:imei => vehicle.imei).sort(:date.desc).first

      if last_report
        start_date = Date.parse(last_report.date.to_s)
      else
        first_movement = Movement.where(:imei => vehicle.imei, :from_timestamp.gt => (Time.now - 3.months).to_i).sort(:from_timestamp).first
        unless first_movement
          logger.debug "No movements found."
          return
        end
        start_date = Time.at(first_movement.from_timestamp).to_date
      end

      current_date = Date.today
      (start_date..current_date).each do |date|
        update_reports_for_date(date, vehicle)
      end
    end

    def update_reports_for_date(date, vehicle)
      logger.debug "Report for date: #{date}"

      conditions = { :imei => vehicle.imei, :from_timestamp.gte => date.to_time.to_i, :from_timestamp.lte => date.to_time.to_i + 86400 }
      movements = Movement.where(conditions).sort(:from_timestamp.desc)

      movement_count = parking_count = movement_time = parking_time = distance = fuel_used = fuel_added = fuel_stolen = 0

      movements.each do |movement|
        if movement.parking
          parking_count += 1
          parking_time += movement.elapsed_time
        else
          movement_count += 1
          movement_time += movement.elapsed_time
          distance += movement.distance
        end
        fuel_used += movement.fuel_used.to_f
      end

      fuel_changes = FuelChange.where(conditions).sort(:from_timestamp.desc)

      fuel_changes.each do |fuel_change|
        if fuel_change.refuel?
          fuel_added += fuel_change.amount
        else
          fuel_stolen += fuel_change.amount
        end
      end

      date_compact = date.to_formatted_s(:date_compact).to_i
      report = Report.where(:imei => vehicle.imei, :date => date_compact).first
      report = Report.new if !report

      report.update_attributes({
        :imei => vehicle.imei,
        :date => date_compact,
        :parking_count => parking_count,
        :movement_count => movement_count,
        :parking_time => parking_time,
        :movement_time => movement_time,
        :distance => distance,
        :fuel_norm => get_fuel_by_norm(vehicle, distance),
        :fuel_used => fuel_used,
        :fuel_added => fuel_added,
        :fuel_stolen => fuel_stolen,
      })

      report.save

      logger.debug "Parkings: #{parking_count} (#{parking_time} sec.), movements: #{movement_count} (#{movement_time} sec.)"
    end

    def update_distance(movement)
      movement.recalculate_distance unless movement.parking
    end

    def get_fuel_by_norm(vehicle, distance)
      return 0 if vehicle.fuel_norm.blank? or (distance.abs <= 0.01)
      distance * vehicle.fuel_norm / 100
    end

end
