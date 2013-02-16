class Driver < ActiveRecord::Base

  validates :name, :presence => true, :length => { :minimum => 3 }
  validate :vehicle_id, :ownership, :allow_blank => true

  attr_accessible :name, :birthday, :license_number, :license_start, :license_end, :categories, :additional_info,
    :owner_id, :vehicle_id

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :vehicle

  def ownership
    if vehicle and !owner_id.blank? and vehicle.user_id != owner.id
      errors.add(:vehicle, :owner_mismatch)
    end 
  end

end
