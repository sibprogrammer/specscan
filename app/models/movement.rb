require 'geocoder'

class Movement

  include MongoMapper::Document

  key :imei
  key :from_timestamp
  key :to_timestamp
  key :from_location
  key :to_location
  key :parking
  key :distance
  key :fuel_used
  key :fuel_last_update_timestamp
  key :compressed
  key :from_location, Location
  key :to_location, Location

  def from_time
    Time.at(from_timestamp)
  end

  def to_time
    Time.at(to_timestamp)
  end

  def from_way_point
    WayPoint.where(:imei => imei, :coors_valid => true, :timestamp.lte => from_timestamp).sort(:timestamp.desc).first
  end

  def to_way_point
    WayPoint.where(:imei => imei, :coors_valid => true, :timestamp.lte => to_timestamp).sort(:timestamp.desc).first
  end

  def elapsed_time
    to_timestamp - from_timestamp
  end

  def recalculate_distance(vehicle)
    points = WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp, :coors_valid => true).all
    total_distance = 0
    prev_point = points.first
    points.each do |point|
      added_distance = prev_point.distance(point)
      # add only if less than 500 km
      total_distance += added_distance if added_distance < 500000
      prev_point = point
    end
    distance_multiplier = vehicle.distance_multiplier.blank? ? 1 : vehicle.distance_multiplier
    self.distance = total_distance * distance_multiplier
    save
  end

  def get_points
    all_points = WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lte => to_timestamp, :coors_valid => true).all

    all_points.collect do |point|
      [point.latitude, point.longitude, Time.at(point.timestamp).to_formatted_s(:time), point.speed.to_i]
    end
  end

  def distance_km
    distance.to_f / 1000
  end

  def update_locations
    location = find_or_create_location(from_way_point)
    self.from_location = location
    location = find_or_create_location(to_way_point) unless parking
    self.to_location = location
    if to_location and from_location
      save
    else
      self.from_location = self.to_location = nil
    end
  end

  def compress
    if parking
      compress_parking
    else
      # TODO: remove points with difference less than one minute
    end

    self.compressed = true
    save
  end

  private

    def find_or_create_location(way_point)
      location = find_nearest_location(way_point)
      unless location
        begin
          location_info = Geocoder.get_address(way_point.latitude, way_point.longitude)
          raise "Unable to detect the location for coordinates: lat - #{way_point.latitude}, lon - #{way_point.longitude}" unless location_info
        rescue Exception => e
          Rails.logger.error e
          return nil
        end
        location = Location.create(location_info.merge({ :coors => [way_point.latitude, way_point.longitude] }))
      end
      location
    end

    def find_nearest_location(way_point)
      location = Location.where({ :coors => { '$near' => [way_point.latitude, way_point.longitude] } }).first
      return nil unless location
      distance = Geocoder.coors_to_distance_haversine(location.coors.first, location.coors.last, way_point.latitude, way_point.longitude)
      return nil if distance > 30
      location
    end

    def compress_parking
      points = WayPoint.where(:imei => imei, :timestamp.gte => from_timestamp, :timestamp.lt => to_timestamp).sort(:timestamp).all
      prev_point = points.shift
      points.each do |point|
        if point.equal(prev_point)
          point.delete
        else
          prev_point = point
        end
      end
    end

end
