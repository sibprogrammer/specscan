class Vehicle < ActiveRecord::Base

  validates :imei, :uniqueness => true, :allow_blank => true, :length => { :in => 5..50 },
    :numericality => { :only_integer => true }
  validates :user_id, :presence => true
  validates :reg_number, :length => { :in => 3..15 }, :allow_blank => true
  validates :name, :presence => true, :uniqueness => { :scope => :user_id }

  attr_accessible :imei, :user_id, :reg_number, :name, :description, :tracker_model_id

  belongs_to :user
  belongs_to :tracker_model

  def total_way_points
     WayPoint.where(:imei => imei).count
  end

  def tracker_name
    tracker_model ? tracker_model.title : ''
  end

end
