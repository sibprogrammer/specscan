require 'test_helper'

class TrackerModelTest < ActiveSupport::TestCase

  test "should not save tracker model without required attributes" do
    tracker_model = TrackerModel.new
    assert !tracker_model.save
  end
  
  test "tracker model should have unique code" do
    tracker_model = TrackerModel.new(:code => 'test', :title => 'Test')
    tracker_model.save
    another_tracker_model = TrackerModel.new(:code => 'test', :title => 'Another Test')
    assert another_tracker_model.invalid?
  end

end
