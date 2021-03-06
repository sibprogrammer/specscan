require 'geocoder'

class WayPoint

  include MongoMapper::Document

  key :imei
  key :latitude
  key :longitude
  key :timestamp
  key :speed
  key :sens_moving
  key :rs232_1
  key :coors_valid
  key :power_input_0
  key :power_input_1
  key :ready
  key :height
  key :engine_on
  key :direction
  key :satellites

  def zero_speed?
    speed.to_f.abs < 1
  end

  def active?
    if power_input_0?
      !power_input_0.blank? and (power_input_0 > 0)
    else
      engine_on
    end
  end

  def activity_support?
    true
  end

  def distance(to_point)
    d = Geocoder.coors_to_distance_haversine(latitude, longitude, to_point.latitude, to_point.longitude)
    return d
    h = (!height.blank? and !to_point.height.blank?) ? (height - to_point.height) : 0
    Math.sqrt(d*d + h*h)
  end

  def time
    Time.at(timestamp.to_i)
  end

  def self.get_by_timestamp(timestamp, imei, conditions = {})
    way_point = WayPoint.where({ :imei => imei, :timestamp.lte => timestamp }.merge(conditions)).sort(:timestamp.desc).first
    (!way_point or (way_point.timestamp - timestamp).abs > 1.year) ? nil : way_point
  end

  def self.nearest_point(timestamp, imei)
    WayPoint.where(:imei => imei, :timestamp.lt => timestamp, :coors_valid => true).sort(:timestamp.desc).first
  end

  def self.find_closest_older(way_point, movement)
    conditions = { :coors_valid => true, :imei => movement.imei, :timestamp => { '$gte' => movement.from_timestamp, '$lte' => movement.to_timestamp } }
    points = WayPoint.where(conditions).sort(:timestamp.desc).all
    prev_point = way_point
    points.each do |point|
      return prev_point if point.distance(way_point) > 2
      prev_point = point
    end
    return
  end

  def find_refuel_start(before_time)
    start_point = self

    conditions = { :imei => start_point.imei, :timestamp.lt => start_point.timestamp }
    points = WayPoint.where(conditions).sort(:timestamp.desc).limit(30).all

    prev_point = start_point
    points.each do |point|
      return start_point if prev_point.fuel_signal <= point.fuel_signal or point.timestamp <= before_time
      start_point = point if prev_point.fuel_signal > point.fuel_signal
      prev_point = point
    end

    start_point
  end

  def fuel_signal
    rs232_1.to_i
  end

  def equal(point)
    return false if !zero_speed? or !point.zero_speed?
    return false if (power_input_0.to_i - point.power_input_0.to_i).abs > 5000
    %w{ imei rs232_1 coors_valid power_input_1 ready engine_on }.each do |field|
      return false if self.send(field) != point.send(field)
    end
    true
  end

end
