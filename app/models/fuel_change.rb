class FuelChange

  include MongoMapper::Document

  key :imei
  key :multiplier
  key :amount
  key :from_timestamp
  key :to_timestamp
  one :way_point

  TRESHOLD_LITRES = 4

  def refuel?
    1 == multiplier
  end

  def from_time
    Time.at(from_timestamp)
  end

  def to_time
    Time.at(to_timestamp)
  end

  def elapsed_time
    to_timestamp - from_timestamp
  end

  def detect_error?
    amount < TRESHOLD_LITRES
  end

end
