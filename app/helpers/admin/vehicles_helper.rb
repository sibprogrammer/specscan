module Admin::VehiclesHelper

  MIN_METERS_BETWEEN_POINTS = 10

  def timeframe(movement)
    "#{movement.from_time.to_formatted_s(:time)} - #{movement.to_time.to_formatted_s(:time)}"
  end

  def movement_info(movement, vehicle_id)
    first_point = get_point_by_timestamp(movement, movement.from_timestamp)
    second_point = get_point_by_timestamp(movement, movement.to_timestamp)

    {
      :vehicle_id => vehicle_id,
      :movement_id => movement.id,
      :title => t('.movement.' + (movement.parking ? 'parking_title' : 'movement_title')),
      :parking => movement.parking,
      :first_point => first_point,
      :last_point => second_point,
      :points => [],
      :from_time => t('.movement.from_time', :time => movement.from_time.to_formatted_s(:date_time)),
      :to_time => t('.movement.to_time', :time => movement.to_time.to_formatted_s(:date_time)),
      :duration => t('.movement.duration', :duration =>  duration_human(movement.elapsed_time)),
      :from_location => movement.from_location ? movement.from_location.address : '',
      :to_location => movement.to_location ? movement.to_location.address : '',
      :distance => movement.parking ? '' : t('.movement.distance', :distance => decimal_human(movement.distance_km)),
    }
  end

  def movement_fuel_used(movement)
    return 0 if movement.fuel_used.to_i < FuelChange::FUEL_TRESHOLD_LITRES
    decimal_human(movement.fuel_used)
  end

  def last_point_info(way_point, title, link = nil)
    {
      :title => title,
      :description => t('.last_point.time', :time => way_point.time.to_formatted_s(:date_time)),
      :latitude => way_point.latitude,
      :longitude => way_point.longitude,
      :link => link ? link : ''
    }
  end

  def tracker_models_list
    list = TrackerModel.all.collect { |model| [model.title, model.id] }
    [[t('admin.vehicles.form.field.unknown_tracker'), 0]] + list
  end

  def duration_human(duration)
    duration = 0 if duration.blank?
    seconds = duration % 60
    minutes = duration / 60
    hours = minutes / 60
    minutes = minutes % 60
    "%d:%.2d" % [hours, minutes]
  end

  def decimal_human(decimal)
    return 0 if decimal.blank?
    "%.1f" % decimal
  end

  def get_point_by_timestamp(movement, timestamp)
    point = WayPoint.where(:imei => movement.imei, :coors_valid => true, :timestamp.lte => timestamp).sort(:timestamp.desc).first
    result = {}
    %w{ latitude longitude }.each{ |name| result[name] = point.send(name)  }
    result
  end

  def get_point_address(way_point)
    location = Location.where({ :coors => { '$near' => [way_point['latitude'], way_point['longitude']] } }).first
    return '' unless location
    return '' if (location.coors.first - way_point['latitude']).abs > 0.01 or (location.coors.last - way_point['longitude']).abs > 0.01
    location.address
  end

end
