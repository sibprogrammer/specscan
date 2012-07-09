require 'test_helper'

class VehicleTest < ActiveSupport::TestCase

  test "should not save vehicle without required attributes" do
    vehicle = Vehicle.new
    assert !vehicle.save
  end

  test "valid vehicle with only required attributes filled" do
    vehicle = Vehicle.new(:name => 'Car X', :user_id => users(:client).id)
    assert vehicle.valid?
  end

  test "valid vehicle with attributes filled" do
    assert vehicles(:car).valid?
    assert vehicles(:truck).valid?
  end

  test "vehicle name should be unique for same user" do
    car = Vehicle.new(:name => 'Car X', :imei => '1234567890', :user_id => users(:client).id)
    car.save
    another_car = Vehicle.new(:name => 'Car X', :imei => '1234567899', :user_id => users(:client).id)
    assert another_car.invalid?
  end

  test "vehicle can have empty imei" do
    vehicle = Vehicle.new(:reg_number => 'X999XX 199', :imei => '')
    assert vehicle.invalid?
  end

  test "vehicle should have unique imei" do
    car = vehicles(:car)
    car_with_same_imei = Vehicle.new(:imei => car.imei, :user => car.user)
    assert car_with_same_imei.invalid?
  end

  test "vehicle should have the owner" do
    car = vehicles(:car)
    car.user = nil
    assert car.invalid?
  end

  test "vehicle with valid imei" do
    car = vehicles(:car)
    car.imei = '1234567890123456'
    assert car.valid?
  end

  test "imei should contain only digits" do
    car = vehicles(:car)

    car.imei = 'abcdef'
    assert car.invalid?

    car.imei = '@#$%^!'
    assert car.invalid?

    car.imei = '123456!'
    assert car.invalid?

    car.imei = '123.456'
    assert car.invalid?
  end

  test "vehicle with too short imei" do
    car = vehicles(:car)
    car.imei = '1234'
    assert car.invalid?
  end

  test "vehicle with shortest imei" do
    car = vehicles(:car)
    car.imei = '12345'
    assert car.valid?
  end

  test "vehicle with valid registration number" do
    car = vehicles(:car)

    car.reg_number = 'X222XX 54'
    assert car.valid?

    car.reg_number = 'X222XX 54 RUS'
    assert car.valid?

    car.reg_number = 'X999XX 154'
    assert car.valid?

    car.reg_number = 'XX999X 154'
    assert car.valid?

    car.reg_number = 'XX 1234 199'
    assert car.valid?

    car.reg_number = 'F123AA'
    assert car.valid?

    car.reg_number = '1234 AA UA'
    assert car.valid?

    car.reg_number = '123-45XX 22'
    assert car.valid?

    car.reg_number = 'Р000МУ'
    assert car.valid?
  end

  test "vehicle with too short registration number" do
    car = vehicles(:car)
    car.reg_number = '12'
    assert car.invalid?
  end

  test "vehicle with shortest registration number" do
    car = vehicles(:car)
    car.reg_number = '123'
    assert car.valid?
  end

  test "vehicle with longest registration number" do
    car = vehicles(:car)
    car.reg_number = '123456789012345'
    assert car.valid?
  end

  test "vehicle with too long registration number" do
    car = vehicles(:car)
    car.reg_number = '1234567890123456'
    assert car.invalid?
  end

  test "registration numbers should be unique" do
    car = Vehicle.new(:name => 'Car', :imei => '1234567890', :user_id => users(:client).id, :reg_number => 'A000AA 154')
    car.save
    another_car = Vehicle.new(:name => 'Car2', :imei => '1234567899', :user_id => users(:client).id, :reg_number => 'A000AA 154')
    assert another_car.invalid?
  end

end
