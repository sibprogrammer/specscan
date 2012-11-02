require 'open-uri'
require 'rexml/document'

class Geocoder

  API_URL = 'http://geocode-maps.yandex.ru/1.x/'

  def self.get_address(latitude, longitude)
    file = open("#{API_URL}?geocode=#{longitude},#{latitude}")
    xml = REXML::Document.new(file)
    return nil if xml.elements.to_a('//found').first.text.to_i < 1
    geo_object = xml.elements.to_a('//GeoObject').first
    address = geo_object.elements.to_a('name').first.text.to_s
    description_tag = geo_object.elements.to_a('description').first
    details = description_tag ? description_tag.text : ''
    { :address => address, :details => details }
  end

  def self.coors_to_distance_haversine(lat1, long1, lat2, long2)
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

  private

    def self.to_rad(ang)
      ang * Math::PI / 180
    end

end
