class FuelSensor < ActiveRecord::Base

  attr_accessible :fuel_sensor_model_id, :code, :comments

  belongs_to :fuel_sensor_model

  def title
    "##{id}" + (code.blank? ? '' : " - #{code}")
  end

  def model
    fuel_sensor_model.title
  end

end
