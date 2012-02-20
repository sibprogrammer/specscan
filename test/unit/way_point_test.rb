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
  
end
