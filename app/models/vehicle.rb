class Vehicle < ActiveRecord::Base

  validates :imei, :presence => true, :uniqueness => true, :length => { :in => 5..50 },
    :numericality => { :only_integer => true }
  validates :user_id, :presence => true
  validates :reg_number, :length => { :in => 3..15 }, :allow_blank => true

  belongs_to :user

  def total_way_points
     WayPoint.where(:imei => imei).count
  end

end
