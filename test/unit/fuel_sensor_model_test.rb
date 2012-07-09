require 'test_helper'

class FuelSensorModelTest < ActiveSupport::TestCase

  test "should not save fuel sensor model without required attributes" do
    fuel_sensor_model = FuelSensorModel.new
    assert !fuel_sensor_model.save
  end

  test "valid fuel sensor model" do
    fuel_sensor_model = FuelSensorModel.new(:title => 'Omnicomm')
    assert fuel_sensor_model.valid?
  end

end
