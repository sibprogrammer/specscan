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

  def zero_speed?
    speed.to_f.abs < 0.1
  end

  def distance(to_point)
    coors_to_distance_haversine(latitude, longitude, to_point.latitude, to_point.longitude)
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

  private

    def to_rad(ang)
      ang * Math::PI / 180
    end

    def coors_to_distance_haversine(lat1, long1, lat2, long2)
      # source: http://www.movable-type.co.uk/scripts/latlong.html
      r = 6_371_000 # radius of the Earth
      lat1, long1 = to_rad(lat1), to_rad(long1)
      lat2, long2 = to_rad(lat2), to_rad(long2)
      dlat = lat2 - lat1
      dlong = long2 - long1
      a = (Math.sin(dlat/2))**2 + ((Math.sin(dlong/2))**2) * Math.cos(lat1) * Math.cos(lat2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      r * c
    end
end
