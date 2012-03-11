class WayPoint

  include MongoMapper::Document

  key :imei
  key :latitude
  key :longitude
  key :timestamp
  key :speed
  key :sens_moving

  def zero_speed?
    speed.to_f.abs < 0.1
  end

  def distance(to_point)
    coors_to_distance_haversine(latitude, longitude, to_point.latitude, to_point.longitude)
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
