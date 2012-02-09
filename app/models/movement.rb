class Movement

  include MongoMapper::Document

  key :imei
  key :from_timestamp
  key :to_timestamp
  key :parking

end
