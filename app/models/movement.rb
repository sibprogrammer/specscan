class Movement

  include MongoMapper::Document

  key :imei
  key :from_timestamp
  key :to_timestamp
  key :parking


  def from_time
    Time.at(from_timestamp)
  end

  def to_time
    Time.at(to_timestamp)
  end

  def info
    {
      :parking => parking,
      :first_point => get_point_by_timestamp(from_timestamp),
      :last_point => get_point_by_timestamp(to_timestamp),
      :points => parking ? [] : get_points(from_timestamp, to_timestamp)
    }
  end

  private

    def get_point_by_timestamp(timestamp)
      point = WayPoint.where(:imei => imei, :timestamp => timestamp).first
      result = {}
      %w{ latitude longitude }.each{ |name| result[name] = point.send(name)  }
      result
    end

    def get_points(from_timestamp, to_timestamp)
      points =  WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp ).all
      points.collect{ |point| { :latitude => point.latitude, :longitude => point.longitude } }
    end

end
