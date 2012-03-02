
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
      :parking => !(way_point.engine_on && way_point.sens_moving)
    })
    last_movement.save
  end

  first_timestamp = last_movement.from_timestamp
  movements_found = [last_movement]

  conditions = {
    :imei => vehicle.imei,
    :timestamp => { :$gt => last_movement.to_timestamp },
  }

  WayPoint.where(conditions).sort(:timestamp).each do |way_point|
    is_parking = !(way_point.engine_on && way_point.sens_moving)

    if last_movement.parking
      if is_parking
        last_movement.to_timestamp = way_point.timestamp
      else
        last_movement = Movement.new({
          :imei => vehicle.imei,
          :from_timestamp => last_movement.to_timestamp,
          :to_timestamp => way_point.timestamp,
          :parking => false
        })
        movements_found << last_movement
      end
    else
      if !is_parking
        last_movement.to_timestamp = way_point.timestamp
      else
        last_movement = Movement.new({
          :imei => vehicle.imei,
          :from_timestamp => last_movement.to_timestamp,
          :to_timestamp => way_point.timestamp,
          :parking => true
        })
        movements_found << last_movement
      end
    end
  end

  index = 1
  movements_found[0].save
  last_saved_movement = movements_found[0]
  while index < (movements_found.count - 1) do
    puts "index #{index} #{movements_found[index].parking}"
    if(movements_found[index].to_timestamp - movements_found[index].from_timestamp < 60) #less than one minute
      last_saved_movement.to_timestamp = movements_found[index + 1].to_timestamp
      last_saved_movement.save
      index += 2
    else
      movements_found[index].save
      last_saved_movement = movements_found[index]
      index += 1
    end
  end
end
