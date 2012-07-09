require 'test_helper'

class MobileOperatorTest < ActiveSupport::TestCase

  test "should not save mobile operator without required attributes" do
    mobile_operator = MobileOperator.new
    assert !mobile_operator.save
  end

  test "valid mobile operator" do
    mobile_operator = MobileOperator.new(:title => 'Test', :code => 'test')
    assert mobile_operator.valid?
  end

  test "mobile operator code should be unique" do
    mobile_operator = MobileOperator.new(:title => 'Test', :code => 'test')
    assert mobile_operator.save

    mobile_operator2 = MobileOperator.new(:title => 'Test 2', :code => 'test')
    assert mobile_operator2.invalid?
  end

  test "mobile operator title should be unique" do
    mobile_operator = MobileOperator.new(:title => 'Test', :code => 'test')
    assert mobile_operator.save

    mobile_operator2 = MobileOperator.new(:title => 'Test', :code => 'test2')
    assert mobile_operator2.invalid?
  end

  test "valid mobile operator code" do
    mobile_operator = MobileOperator.new(:title => 'Test')

    mobile_operator.code = 'abc123'
    assert mobile_operator.valid?

    mobile_operator.code = 'abc 123'
    assert mobile_operator.invalid?

    mobile_operator.code = 'abc-123'
    assert mobile_operator.invalid?

    mobile_operator.code = 'abc#$%'
    assert mobile_operator.invalid?

    mobile_operator.code = 'ABC'
    assert mobile_operator.invalid?
  end

end
