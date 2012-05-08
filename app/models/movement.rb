class Movement

  include MongoMapper::Document

  key :imei
  key :from_timestamp
  key :to_timestamp
  key :parking
  key :distance

  def from_time
    Time.at(from_timestamp)
  end

  def to_time
    Time.at(to_timestamp)
  end

  def elapsed_time
    to_timestamp - from_timestamp
  end

  def recalculate_distance
    points = WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp, :coors_valid => true).all
    distance = 0
    prev_point = points.first
    points.each do |point|
      distance += prev_point.distance(point)
      prev_point = point
    end
    self.distance = distance
    save
  end

  def get_points
    all_points = WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp, :coors_valid => true).all

    all_points.collect do |point|
      [point.latitude, point.longitude, Time.at(point.timestamp).to_formatted_s(:time), point.speed]
    end
  end

end
