require 'test_helper'

class DriverTest < ActiveSupport::TestCase

  test "should not save driver without required attributes" do
    driver = Driver.new
    assert !driver.save
  end

  test "valid driver with only required attributes filled" do
    driver = Driver.new(:name => 'test')
    assert driver.valid?
  end

  test "driver with too short name" do
    driver = Driver.new(:name => 'ab')
    assert driver.invalid?
  end

  test "valid with all fields filled" do
    driver = drivers(:ivan)
    assert driver.valid?
  end

end
