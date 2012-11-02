class Location

  include MongoMapper::Document

  key :coors
  key :address
  key :city
  key :country

  ensure_index [[:coors, '2d']]

end
