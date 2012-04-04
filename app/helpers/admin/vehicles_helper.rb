module Admin::VehiclesHelper

  MIN_METERS_BETWEEN_POINTS = 10

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
      :from_time => t('.movement.from_time', :time => movement.from_time.to_formatted_s(:date_time)),
      :to_time => t('.movement.to_time', :time => movement.to_time.to_formatted_s(:date_time)),
      :duration => t('.movement.duration', :duration =>  duration_human(duration)),
    }
  end

  def last_point_info(way_point)
    {
      :title => t('.last_point.title'),
      :description => t('.last_point.time', :time => way_point.time.to_formatted_s(:date_time)),
      :latitude => way_point.latitude,
      :longitude => way_point.longitude,
    }
  end

  def tracker_models_list
    list = TrackerModel.all.collect { |model| [model.title, model.id] }
    [[t('admin.vehicles.form.field.unknown_tracker'), 0]] + list
  end

  private

    def get_point_by_timestamp(movement, timestamp)
      point = WayPoint.where(:imei => movement.imei, :timestamp => timestamp).first
      result = {}
      %w{ latitude longitude }.each{ |name| result[name] = point.send(name)  }
      result
    end

    def get_points(movement, from_timestamp, to_timestamp)
      all_points = WayPoint.where(:imei => movement.imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp ).all
      important_points = []
      prev_point = nil

      all_points.each do |point|
        if !prev_point or prev_point.distance(point) > MIN_METERS_BETWEEN_POINTS
          important_points << point
          prev_point = point
        end
      end

      important_points.collect{ |point| {
        :latitude => point.latitude,
        :longitude => point.longitude,
        :time => t('.movement.time', :time => Time.at(point.timestamp).to_formatted_s(:time)),
        :speed => t('.movement.speed', :speed => point.speed),
      }}
    end

    def duration_human(duration)
      seconds = duration % 60
      minutes = duration / 60
      hours = minutes / 60
      minutes = minutes % 60
      "%d:%.2d" % [hours, minutes]
    end

end
