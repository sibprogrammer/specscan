module Admin::VehiclesHelper

  def timeframe(movement)
    "#{movement.from_time.to_formatted_s(:time)} - #{movement.to_time.to_formatted_s(:time)}"
  end

  def movement_info(movement)
    first_point = get_point_by_timestamp(movement, movement.from_timestamp)
    second_point = get_point_by_timestamp(movement, movement.to_timestamp)
    duration = movement.to_timestamp - movement.from_timestamp

    {
      :title => t('.movement.' + (movement.parking ? 'parking_title' : 'movement_title')),
      :parking => movement.parking,
      :first_point => first_point,
      :last_point => second_point,
      :points => movement.parking ? [] : get_points(movement, movement.from_timestamp, movement.to_timestamp),
      :timeframe => t('.movement.time', :time => "#{movement.from_time.to_formatted_s(:time)} - #{movement.to_time.to_formatted_s(:time)}"),
      :duration => t('.movement.duration', :duration =>  duration_human(duration)),
    }
  end

  private

    def get_point_by_timestamp(movement, timestamp)
      point = WayPoint.where(:imei => movement.imei, :timestamp => timestamp).first
      result = {}
      %w{ latitude longitude }.each{ |name| result[name] = point.send(name)  }
      result
    end

    def get_points(movement, from_timestamp, to_timestamp)
      points =  WayPoint.where(:imei => movement.imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp ).all
      points.collect{ |point| { :latitude => point.latitude, :longitude => point.longitude } }
    end

    def duration_human(duration)
      seconds = duration % 60
      minutes = duration / 60
      hours = minutes / 60
      minutes = minutes % 60
      "%d:%.2d" % [hours, minutes]
    end

end
