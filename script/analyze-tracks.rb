def close_point?(way_point, imei)
  conditions = {
    :imei => imei,
    :coors_valid => true,
    :timestamp => { :$gt => way_point.timestamp - 3.minutes },
    :order => :timestamp
  }
  prev_point = WayPoint.first(conditions)
  return true if (way_point.timestamp - prev_point.timestamp) < 2.minutes

  way_point.distance(prev_point) < 70
end

Vehicle.all.each do |vehicle|

  puts "Vehicle ##{vehicle.id} (IMEI: #{vehicle.imei})"

  last_movement = Movement.where(:imei => vehicle.imei).sort(:to_timestamp).last

  if !last_movement
    first_way_point = WayPoint.where(:imei => vehicle.imei, :timestamp => { :$gt => 0 }).sort(:timestamp).first
    next if !first_way_point
    last_movement = Movement.new({
      :imei => vehicle.imei,
      :from_timestamp => first_way_point.timestamp.to_i,
      :to_timestamp => first_way_point.timestamp.to_i,
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
    is_parking = close_point?(way_point, vehicle.imei)

    if last_movement.parking
      if is_parking
        last_movement.to_timestamp = way_point.timestamp
        last_movement.save
      else
        last_movement = Movement.new({
          :imei => vehicle.imei,
          :from_timestamp => last_movement.to_timestamp,
          :to_timestamp => way_point.timestamp,
          :parking => false
        })
        last_movement.save
      end
    else
      if !is_parking
        last_movement.to_timestamp = way_point.timestamp
        last_movement.save
      else
        last_movement = Movement.new({
          :imei => vehicle.imei,
          :from_timestamp => last_movement.to_timestamp,
          :to_timestamp => way_point.timestamp,
          :parking => true
        })
        last_movement.save
      end
    end
  end

end
