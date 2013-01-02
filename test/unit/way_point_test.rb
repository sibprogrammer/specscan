require 'test_helper'

class WayPointTest < ActiveSupport::TestCase
  
  test "distance between two geo points" do
    first_point = WayPoint.new(:longitude => 82.952386, :latitude => 55.044202)
    second_point = WayPoint.new(:longitude => 82.960797, :latitude => 55.048851)
    assert_in_delta(745, first_point.distance(second_point), 3)
    
    first_point = WayPoint.new(:longitude => 82.960561, :latitude => 55.048538)
    second_point = WayPoint.new(:longitude => 82.962449, :latitude => 55.041581)
    assert_in_delta(783, first_point.distance(second_point), 3)
  end

  test "equal points" do
    first_point = get_point
    same_point = get_point
    assert first_point.equal(same_point)
    assert same_point.equal(first_point)

    first_point = get_point(:power_input_0 => 14500)
    same_point = get_point(:power_input_0 => 12500)
    assert first_point.equal(same_point)

    first_point = get_point
    different_point = get_point(:speed => 10)
    assert !first_point.equal(different_point)

    first_point = get_point(:power_input_0 => 0)
    different_point = get_point(:power_input_0 => 10000)
    assert !first_point.equal(different_point)
  end

  private

    def get_point(overrides = {})
      WayPoint.new({
        :imei => 100000001,
        :latitude => 82,
        :longitude => 55,
        :timestamp => 123,
        :speed => 0,
        :engine_on => false,
        :ready => true,
      }.merge(overrides))
    end

end
