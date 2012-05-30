class FuelSensorModel < ActiveRecord::Base

  validates :title, :uniqueness => true, :presence => true

end
