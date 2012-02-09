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

end
