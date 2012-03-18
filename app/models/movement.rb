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

  def timespan_human(timespan)
    seconds = timespan % 60
    minutes = timespan / 60
    hours = minutes / 60
    minutes = minutes % 60
    "%.2d:%.2d" % [hours, minutes]
  end

  def info
    first_point = get_point_by_timestamp(from_timestamp)
    second_point = get_point_by_timestamp(to_timestamp)
    timespan = to_timestamp - from_timestamp

    {
      :parking => parking,
      :first_point => first_point,
      :last_point => second_point,
      :points => parking ? [] : get_points(from_timestamp, to_timestamp),
      :timeframe => "#{from_time.to_formatted_s(:time)} - #{to_time.to_formatted_s(:time)}",
      :timespan => timespan_human(timespan),
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
