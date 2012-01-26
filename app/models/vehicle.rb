class Vehicle < ActiveRecord::Base

  validates :imei, :presence => true, :uniqueness => true

  belongs_to :user

  def total_way_points
     WayPoint.where(:imei => imei).count
  end

end
