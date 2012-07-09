require 'test_helper'

class VehicleTypeTest < ActiveSupport::TestCase

  test "should not save vehicle type without required attributes" do
    vehicle_type = VehicleType.new
    assert !vehicle_type.save
  end

  test "valid vehicle type" do
    vehicle_type = VehicleType.new(:title => 'Truck', :code => 'truck')
    assert vehicle_type.valid?
  end

  test "vehicle type code should be unique" do
    vehicle_type = VehicleType.new(:title => 'Truck', :code => 'truck')
    assert vehicle_type.save

    another_vehicle_type = VehicleType.new(:title => 'Car', :code => 'truck')
    assert another_vehicle_type.invalid?
  end

  test "vehicle type title should be unique" do
    vehicle_type = VehicleType.new(:title => 'Truck', :code => 'truck')
    assert vehicle_type.save

    another_vehicle_type = VehicleType.new(:title => 'Truck', :code => 'car')
    assert another_vehicle_type.invalid?
  end

  test "valid vehicle type code" do
    vehicle_type = VehicleType.new(:title => 'Truck')

    vehicle_type.code = 'truck'
    assert vehicle_type.valid?

    vehicle_type.code = 'truck123'
    assert vehicle_type.invalid?

    vehicle_type.code = 'abc 123'
    assert vehicle_type.invalid?

    vehicle_type.code = 'abc-123'
    assert vehicle_type.invalid?

    vehicle_type.code = 'abc#$%'
    assert vehicle_type.invalid?

    vehicle_type.code = 'ABC'
    assert vehicle_type.invalid?
  end

end
