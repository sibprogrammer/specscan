require 'test_helper'

class FuelSensorTest < ActiveSupport::TestCase

  test "should not save fuel sensor without required attributes" do
    fuel_sensor = FuelSensor.new
    assert !fuel_sensor.save

    fuel_sensor.code = '1234'
    assert !fuel_sensor.save
  end

  test "valid fuel sensor" do
    fuel_sensor = FuelSensor.new(:code => '1234', :fuel_sensor_model_id => 1)
    assert fuel_sensor.valid?
  end

  test "fuel sensor code should be unique" do
    fuel_sensor = FuelSensor.new(:code => '123', :fuel_sensor_model_id => 1)
    assert fuel_sensor.save

    another_fuel_sensor = FuelSensor.new(:code => '123', :fuel_sensor_model_id => 1)
    assert another_fuel_sensor.invalid?
  end

  test "valid fuel sensor code" do
    fuel_sensor = FuelSensor.new(:fuel_sensor_model_id => 1)

    fuel_sensor.code = '123'
    assert fuel_sensor.valid?

    ['123 456', '123-444', 'abc'].each do |code|
      fuel_sensor.code = code
      assert fuel_sensor.invalid?
    end
  end

end
