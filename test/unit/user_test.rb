require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should not save user without required attributes" do
    user = User.new
    assert !user.save
  end

  test "valid user with only required attributes filled" do
    user = User.new(:login => 'test', :password => 'test123', :role => 2)
    assert user.valid?
  end

  test "user should have role defined" do
    user = User.new(:login => 'test', :password => 'test123', :role => nil)
    assert user.invalid?
  end

  test "user with shortest login" do
    user = User.new(:login => 'abc', :password => 'test123')
    assert user.valid?
  end

  test "user with too short login" do
    user = User.new(:login => 'ab', :password => 'test123')
    assert user.invalid?
  end

  test "user with longest login" do
    user = User.new(:login => '123456789012345', :password => 'test123')
    assert user.valid?
  end

  test "user with too long login" do
    user = User.new(:login => '123456789012345678901', :password => 'test123')
    assert user.invalid?
  end

  test "user logins are always in lower case" do
    user = User.new(:login => 'CAPS', :password => 'test123', :email => 'email@example.dom')
    assert_equal 'caps', user.login
  end

  test "user login should not contain special characters" do
    user = User.new(:login => 'test!', :password => '123456')
    assert user.invalid?
  end

  test "user login can contain dashes" do
    user = User.new(:login => 'company-user', :password => '123456')
    assert user.valid?
  end

  test "user password should not contain special characters" do
    user = User.new(:login => 'test', :password => 'test123!')
    assert user.invalid?
  end

  test "user with shortest password" do
    user = User.new(:login => 'test', :password => '123456')
    assert user.valid?
  end

  test "user with too short password" do
    user = User.new(:login => 'test', :password => '12345')
    assert user.invalid?
  end

  test "user with longest password" do
    user = User.new(:login => 'test', :password => '1234567890123456789012345')
    assert user.valid?
  end

  test "user with too long password" do
    user = User.new(:login => 'test', :password => '12345678901234567890123456')
    assert user.invalid?
  end

  test "user with email" do
    user = User.new(:login => 'test', :password => 'test123', :email => 'email@example.dom')
    assert user.valid?
  end

  test "user should have valid email" do
    user = User.new(:login => 'test', :password => 'test123', :email => 'invalid')
    assert user.invalid?
  end

  test "user with role admin" do
    assert users(:admin).admin?
  end

  test "user with role client" do
    assert users(:client).client?
  end

  test "admin user role name" do
    assert_equal 'admin', users(:admin).role_name
  end

  test "client user role name" do
    assert_equal 'client', users(:client).role_name
  end

end
