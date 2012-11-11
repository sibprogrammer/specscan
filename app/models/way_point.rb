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
  key :ready

  def zero_speed?
    speed.to_f.abs < 0.1
  end

  def active?
    !power_input_0.blank? and (power_input_0 > 0)
  end

  def activity_support?
    power_input_0?
  end

  def distance(to_point)
    Geocoder.coors_to_distance_haversine(latitude, longitude, to_point.latitude, to_point.longitude)
  end

  def time
    Time.at(timestamp)
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

  def fuel_signal
    rs232_1.to_i
  end

end
