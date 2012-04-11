require 'server/abstract'

module Server; end

class Server::Analyzer < Server::Abstract

  MIN_METERS_FOR_MOVEMENT_START = 3
  MIN_SECONDS_FOR_PARKING_WITH_ENGINE_ON = 120

  def initialize
    @log_file = "#{Rails.root}/log/analyzer.log"
  end

  def start
    loop do
      Vehicle.with_imei.each do |vehicle|
        update_movements(vehicle)
      end
      sleep(5.minutes.to_i)
    end
  end

  private

    def update_movements(vehicle)
      logger.debug "Updating tracks for vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

      last_movement = Movement.where(:imei => vehicle.imei).sort(:to_timestamp).last

      if !last_movement
        first_way_point = WayPoint.where(:imei => vehicle.imei).sort(:timestamp).first
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
        :coors_valid => true,
        :timestamp => { :$gt => last_movement.to_timestamp },
      }

      WayPoint.where(conditions).sort(:timestamp).each do |way_point|
        last_movement = analyze_way_point(way_point, vehicle.imei, last_movement)
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
          if way_point.distance(WayPoint.get_by_timestamp(last_movement.from_timestamp, imei)) > MIN_METERS_FOR_MOVEMENT_START
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

          if (prev_way_point.engine_on or prev_way_point.sens_moving) and prev_way_point.timestamp > last_movement.from_timestamp
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
          if prev_way_point.timestamp > last_movement.from_timestamp and prev_way_point.distance(way_point) < MIN_METERS_FOR_MOVEMENT_START
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

end
