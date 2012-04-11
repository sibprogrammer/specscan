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

  def elapsed_time
    to_timestamp - from_timestamp
  end

end
