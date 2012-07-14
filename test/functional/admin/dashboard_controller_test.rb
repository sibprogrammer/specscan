require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in users(:admin)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
