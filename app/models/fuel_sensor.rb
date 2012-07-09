class FuelSensor < ActiveRecord::Base

  validates :code, :uniqueness => true, :presence => true, :format => { :with => /\A\d+\z/ }
  validates :fuel_sensor_model_id, :presence => true

  attr_accessible :fuel_sensor_model_id, :code, :comments, :vehicle_id

  belongs_to :fuel_sensor_model
  belongs_to :vehicle

  def model
    fuel_sensor_model.title
  end

end
