class VehicleType < ActiveRecord::Base

  validates :code, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => true

end
