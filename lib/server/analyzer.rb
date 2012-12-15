require 'server/abstract'

module Server; end

class Server::Analyzer < Server::Abstract

  MIN_METERS_FOR_MOVEMENT_START = 3
  MAX_METERS_FOR_FALSE_MOVEMENT_START = 1000
  MIN_SECONDS_FOR_PARKING_WITH_ENGINE_ON = 120
  MIN_SPEED_KM = 3
  FUEL_TRESHOLD_MOVEMENT_LITRES = 15
  FUEL_TRESHOLD_PARKING_LITRES = 8
  MIN_SECONDS_BETWEEN_REFILLS = 180

  def initialize
    @log_file = "#{Rails.root}/log/analyzer.log"
  end

  def start
    loop do
      Vehicle.with_imei.each do |vehicle|
        if WayPoint.where(:imei => vehicle.imei, :ready => false).count > 0
          logger.debug "Not ready way points found for imei #{vehicle.imei}, stop analyzing of way points"
          next
        end

        update_movements(vehicle)
        update_fuel_changes(vehicle) if vehicle.fuel_sensor
        update_reports(vehicle)
      end

      update_locations

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
      prev_way_point = WayPoint.where(:imei => vehicle.imei, :timestamp.lte => last_movement.to_timestamp).sort(:timestamp.desc).first

      total_way_points = WayPoint.where(conditions).sort(:timestamp).count
      logger.debug "Found way points: #{total_way_points} (conditions: #{conditions.inspect})"

      1.upto((total_way_points.to_f / 1000).ceil).each do
        conditions[:timestamp] = { :$gt => last_movement.to_timestamp }
        way_points = WayPoint.where(conditions).sort(:timestamp).limit(1000)
        logger.debug "Not processed way points: #{way_points.count}"

        way_points.each do |way_point|
          update_activity_changes(way_point, vehicle) if vehicle.has_activity_sensor?
          prev_way_point = way_point unless 0 == way_point.fuel_signal
          last_movement = analyze_way_point(way_point, vehicle, last_movement)
          movements << last_movement if last_movement.id.to_s != movements.last.id.to_s
        end
      end

      logger.debug "Re-calculate distances for #{movements.count} movements"
      movements.each{ |movement| movement.recalculate_distance(vehicle) unless movement.parking }
    end

    def update_activity_changes(way_point, vehicle)
      return unless way_point.activity_support?
      prev_activity_change = Activity.where(:imei => vehicle.imei, :to_timestamp.lt => way_point.timestamp).sort(:to_timestamp.desc).first

      if !prev_activity_change
        logger.debug "Initial activity was created."
        activity_change = Activity.create({
          :imei => vehicle.imei,
          :from_timestamp => way_point.timestamp,
          :to_timestamp => way_point.timestamp,
          :active => way_point.active?
        })
        return
      end

      if prev_activity_change.active != way_point.active?
        return if (way_point.timestamp - prev_activity_change.from_timestamp) < 2
        logger.debug "Activity state was changed (was: #{prev_activity_change.active}, now: #{way_point.active?}, time: #{way_point.timestamp}, #{Time.at(way_point.timestamp)})."
        add_activity_change(prev_activity_change, way_point)

        activity_change = Activity.create({
          :imei => vehicle.imei,
          :from_timestamp => way_point.timestamp,
          :to_timestamp => way_point.timestamp,
          :active => way_point.active?
        })
      else
        add_activity_change(prev_activity_change, way_point)
      end
    end

    def add_activity_change(activity_change, way_point)
      if Time.at(activity_change.to_timestamp).yday == Time.at(way_point.timestamp).yday
        activity_change.to_timestamp = way_point.timestamp - 1
        activity_change.save
        return
      end

      activity_change.to_timestamp = Time.at(activity_change.to_timestamp).end_of_day.to_i
      activity_change.save

      Activity.create({
        :imei => activity_change.imei,
        :from_timestamp => Time.at(way_point.timestamp).beginning_of_day.to_i,
        :to_timestamp => way_point.timestamp - 1,
        :active => activity_change.active
      })
    end

    def update_fuel_changes(vehicle)
      logger.debug "Updating fuel changes for vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

      if ('native' == vehicle.fuel_sensor.fuel_sensor_model.code)
        logger.debug "Feature is not available for native fuel sensors."
        return
      end

      movement = Movement.where(:imei => vehicle.imei, :fuel_last_update_timestamp.gt => 0).sort(:to_timestamp.desc).first
      last_way_point = WayPoint.where(:imei => vehicle.imei, :timestamp.gte => movement.fuel_last_update_timestamp).sort(:timestamp).first if movement
      from_timestamp = last_way_point.timestamp + 1 if last_way_point

      logger.debug "Start from previous last point, timestamp: #{from_timestamp}" if from_timestamp

      if !from_timestamp
        last_way_point = WayPoint.where(:imei => vehicle.imei, :coors_valid => true).sort(:timestamp).first
        return if !last_way_point
        from_timestamp = last_way_point.timestamp
      end

      to_timestamp = Time.now.to_i - 5.minutes
      logger.debug "Find points from #{from_timestamp}, #{Time.at(from_timestamp)} to #{to_timestamp}, #{Time.at(to_timestamp)}"

      prev_way_point = WayPoint.where(:imei => vehicle.imei, :coors_valid => true, :timestamp.lt => from_timestamp).sort(:timestamp.desc).first

      way_points = WayPoint.where(:imei => vehicle.imei, :timestamp => { :$gt => from_timestamp, :$lt => to_timestamp }).sort(:timestamp)
      logger.debug "Found way points: #{way_points.count}"

      way_points.each do |way_point|
        movement = Movement.where(:imei => vehicle.imei, :from_timestamp.lt => way_point.timestamp, :to_timestamp.gte => way_point.timestamp).sort(:to_timestamp).first
        next unless movement
        movement.fuel_last_update_timestamp = way_point.timestamp
        movement.save
        analyze_fuel_changes(way_point, prev_way_point, vehicle, movement) if prev_way_point
        prev_way_point = way_point unless 0 == way_point.fuel_signal
        last_way_point = way_point
      end

      logger.debug "Fuel changes analysis was finished."
    end

    def analyze_fuel_changes(way_point, prev_way_point, vehicle, movement)
      # ignore sensor invalid values
      return if 0 == prev_way_point.fuel_signal or 0 == way_point.fuel_signal

      fuel_diff = vehicle.get_fuel_amount(prev_way_point) - vehicle.get_fuel_amount(way_point)
      return if fuel_diff.abs < 0.01

      prev_fuel_change = FuelChange.where(:imei => vehicle.imei, :to_timestamp.lt => way_point.timestamp).sort(:to_timestamp.desc).first

      if movement.parking
        fuel_minor_change = true
        fuel_minor_change = false if fuel_diff.abs >= FUEL_TRESHOLD_PARKING_LITRES
        within_last_refuel = (prev_fuel_change and prev_fuel_change.to_timestamp >= prev_way_point.timestamp)
        fuel_minor_change = false if prev_way_point.timestamp >= movement.from_timestamp and fuel_diff.abs > 1 and fuel_diff < 0 and within_last_refuel
        logger.debug "Parking, fuel major change" unless fuel_minor_change
      else
        fuel_minor_change = true
        fuel_minor_change = false if fuel_diff.abs > FUEL_TRESHOLD_PARKING_LITRES and prev_way_point.timestamp < movement.from_timestamp
        fuel_minor_change = false if fuel_diff.abs > FUEL_TRESHOLD_MOVEMENT_LITRES
        logger.debug "Movement, fuel major change" unless fuel_minor_change
      end

      if fuel_minor_change
        movement.fuel_used = (movement.fuel_used.to_f + fuel_diff).to_f
        movement.save
      else
        multiplier = (fuel_diff > 0) ? -1 : 1

        if prev_fuel_change and prev_fuel_change.multiplier == multiplier and (way_point.timestamp - prev_fuel_change.to_timestamp) < MIN_SECONDS_BETWEEN_REFILLS
          prev_fuel_change.to_timestamp = way_point.timestamp
          prev_fuel_change.amount += fuel_diff.abs.to_f
          prev_fuel_change.save

          logger.debug "#{fuel_diff} litres were added to previous fuel change."
        else
          start_way_point = way_point
          if fuel_diff < 0
            before_time = prev_fuel_change ? prev_fuel_change.to_timestamp : 0
            start_way_point = way_point.find_refuel_start(before_time)
            if start_way_point.id.to_s != way_point.id.to_s
              fuel_diff = vehicle.get_fuel_amount(start_way_point) - vehicle.get_fuel_amount(way_point)
            end
          end

          FuelChange.create({
            :imei => vehicle.imei,
            :multiplier => multiplier,
            :amount => fuel_diff.abs.to_f,
            :from_timestamp => start_way_point.timestamp,
            :to_timestamp => way_point.timestamp,
            :way_point => way_point,
          })

          logger.debug "New fuel change detected: #{fuel_diff} litres at #{start_way_point.timestamp}, #{Time.at(start_way_point.timestamp)}"
        end
      end
    end

    def analyze_way_point(way_point, vehicle, last_movement)
      if !way_point.coors_valid
        last_movement = add_way_point(last_movement, way_point)
        return last_movement
      end

      if (way_point.timestamp - last_movement.to_timestamp) > 10.minutes.to_i
        logger.debug "Large timespan between points: #{way_point.timestamp - last_movement.to_timestamp} sec."
        if last_movement.parking
          last_movement = add_way_point(last_movement, way_point)
        else
          last_movement = create_parking(vehicle.imei, last_movement, way_point)
        end

        last_movement.save
        return last_movement
      end

      if last_movement.parking
        # if last was a parking
        stopped_state = vehicle.has_activity_sensor? ? (!way_point.engine_on or way_point.zero_speed?) : (!way_point.engine_on and !way_point.sens_moving)
        if stopped_state
          last_movement = add_way_point(last_movement, way_point)
        else
          distance = way_point.distance(WayPoint.get_by_timestamp(last_movement.from_timestamp, vehicle.imei, :coors_valid => true))
          if distance > MIN_METERS_FOR_MOVEMENT_START and way_point.speed > MIN_SPEED_KM
            last_movement.save
            last_movement = create_movement(vehicle.imei, last_movement, way_point)
          else
            last_movement = add_way_point(last_movement, way_point)
          end
        end

        last_movement.save
      else
        # if last was a movement
        if vehicle.has_activity_sensor? and !way_point.engine_on
          last_movement.save
          last_movement = create_parking(vehicle.imei, last_movement, way_point)
        else
          min_seconds_for_parking_with_engine_on = vehicle.min_parking_time? ? vehicle.min_parking_time : MIN_SECONDS_FOR_PARKING_WITH_ENGINE_ON
          prev_way_point = WayPoint.nearest_point(way_point.timestamp - min_seconds_for_parking_with_engine_on, vehicle.imei)
          if way_point.zero_speed? and prev_way_point and prev_way_point.timestamp > last_movement.from_timestamp and
            (!way_point.coors_valid or prev_way_point.distance(way_point) < MIN_METERS_FOR_MOVEMENT_START)
            last_movement = add_way_point(last_movement, prev_way_point)
            last_movement.save
            last_movement = create_parking(vehicle.imei, last_movement, way_point)
          else
            last_movement = add_way_point(last_movement, way_point)
          end
        end

        last_movement.save
      end

      last_movement
    end

    def add_way_point(movement, way_point)
      if Time.at(movement.to_timestamp).yday == Time.at(way_point.timestamp).yday
        movement.to_timestamp = way_point.timestamp
        return movement
      end

      movement.to_timestamp = Time.at(movement.to_timestamp).end_of_day.to_i
      movement.save

      Movement.new({
        :imei => movement.imei,
        :from_timestamp => Time.at(way_point.timestamp).beginning_of_day.to_i,
        :to_timestamp => way_point.timestamp,
        :parking => movement.parking
      })
    end

    def create_parking(imei, last_movement, way_point)
      logger.debug "Parking started from: #{last_movement.from_timestamp}, #{Time.at(last_movement.from_timestamp)}"

      movement = Movement.new({
        :imei => imei,
        :from_timestamp => last_movement.to_timestamp,
        :to_timestamp => last_movement.to_timestamp,
        :parking => true
      })
      add_way_point(movement, way_point)
    end

    def create_movement(imei, last_movement, way_point)
      logger.debug "Movement started from: #{last_movement.from_timestamp}, #{Time.at(last_movement.from_timestamp)}"

      movement = Movement.new({
        :imei => imei,
        :from_timestamp => last_movement.to_timestamp,
        :to_timestamp => last_movement.to_timestamp,
        :parking => false
      })
      add_way_point(movement, way_point)
    end

    def update_reports(vehicle)
      logger.debug "Updating reports for vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

      last_report = Report.where(:imei => vehicle.imei, :parking_time.gt => 0).sort(:date.desc).first

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

      conditions = { :imei => vehicle.imei, :from_timestamp.gte => date.to_time.to_i, :from_timestamp.lt => date.to_time.to_i + 86400 }
      movements = Movement.where(conditions).sort(:from_timestamp.desc)

      movement_count = parking_count = movement_time = parking_time = distance = fuel_used = fuel_added = fuel_stolen = active_time = 0

      movements.each do |movement|
        if movement.parking
          parking_count += 1
          parking_time += movement.elapsed_time
        else
          movement_count += 1
          movement_time += movement.elapsed_time
          distance += movement.distance.to_i
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

      activity_changes = Activity.where(conditions).sort(:from_timestamp.desc)
      activity_changes.each{ |activity_change| active_time += activity_change.elapsed_time if activity_change.active }

      date_compact = date.to_formatted_s(:date_compact).to_i
      report = Report.where(:imei => vehicle.imei, :date => date_compact).first
      report = Report.new if !report

      fuel_norm = get_fuel_by_norm(vehicle, distance, active_time)
      logger.debug "Fuel by norm: #{fuel_norm} litres"

      report.update_attributes({
        :imei => vehicle.imei,
        :date => date_compact,
        :parking_count => parking_count,
        :movement_count => movement_count,
        :parking_time => parking_time,
        :movement_time => movement_time,
        :distance => distance,
        :fuel_norm => fuel_norm,
        :fuel_used => fuel_used,
        :fuel_added => fuel_added,
        :fuel_stolen => fuel_stolen,
        :active_time => active_time,
      })

      report.save

      logger.debug "Parkings: #{parking_count} (#{parking_time} sec.), movements: #{movement_count} (#{movement_time} sec.)"
      logger.debug "Report: #{report.inspect}"
    end

    def update_distances(vehicle)
      movements = Movement.where({ :imei => vehicle.imei, :to_timestamp.gte => Time.now.beginning_of_day.to_i })
      logger.debug "Re-calculate distances for #{movements.count} movements"

      movements.each do |movement|
        movement.recalculate_distance(vehicle) unless movement.parking
      end
    end

    def get_fuel_by_norm(vehicle, distance, active_time)
      return 0 if vehicle.fuel_norm.blank?

      if Vehicle::FUEL_CALC_BY_DISTANCE == vehicle.fuel_calc_method
        return 0 if (distance.abs <= 0.01)
        return (distance.to_f * vehicle.fuel_norm / 100).to_f
      elsif Vehicle::FUEL_CALC_BY_MHOURS == vehicle.fuel_calc_method
        return 0 if active_time < 1.minute
        return (active_time.to_f / 1.hour * vehicle.fuel_norm).to_f
      else
        # unknown calculation method
        return 0
      end
    end

    def update_locations
      conditions = { :from_location => nil, :from_timestamp.gt => (Time.now.to_i - 2.months) }
      movements = Movement.where(conditions).sort(:from_timestamp.desc).limit(200)
      logger.debug "Total not processed movements without locations info: #{movements.count}"
      movements.each do |movement|
        next if !movement.parking and (Time.now.to_i - movement.to_timestamp < 5.minutes)
        movement.update_locations
      end
      logger.debug "Locations update have been finished."
    end

end
