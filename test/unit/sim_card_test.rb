require 'test_helper'

class SimCardTest < ActiveSupport::TestCase

  test "should not save SIM card without required attributes" do
    sim_card = SimCard.new
    assert !sim_card.save
  end

  test "SIM card should have an operator" do
    sim_card = SimCard.new(:phone => '1234567890')
    assert sim_card.invalid?
  end

  test "phone should contain only digits" do
    sim_card = SimCard.new(:mobile_operator_id => 1)

    sim_card.phone = '9139130000'
    assert sim_card.valid?

    sim_card.phone = '123-321'
    assert sim_card.invalid?

    sim_card.phone = '+123'
    assert sim_card.invalid?

    sim_card.phone = '12345'
    assert sim_card.invalid?
  end

  test "phone should be unique" do
    sim_card = SimCard.new(:mobile_operator_id => 1, :phone => '1234567890')
    assert sim_card.save

    sim_card2 = SimCard.new(:mobile_operator_id => 1, :phone => '1234567890')
    assert sim_card2.invalid?
  end

  test "internet helper password should contain letters and digits" do
    sim_card = SimCard.new(:mobile_operator_id => 1, :phone => '1234567890')

    sim_card.helper_password = 'abc123'
    assert sim_card.valid?

    sim_card.helper_password = 'abc 123'
    assert sim_card.invalid?

    sim_card.helper_password = 'abc123#$%'
    assert sim_card.invalid?
  end

  test "internet helper password should be stored in encrypted form" do
    sim_card = SimCard.new(:mobile_operator_id => 1, :phone => '1234567890')

    sim_card.helper_password = 'abc123'
    assert_equal sim_card.helper_password, 'abc123'

    assert_not_equal sim_card.helper_password, sim_card.read_attribute(:helper_password)
  end

  test "pin code should consist of digits" do
    sim_card = sim_cards(:typical)

    sim_card.pin_code = 1234
    assert sim_card.valid?

    sim_card.pin_code = 'abcd'
    assert sim_card.invalid?
  end

  test "puk code should consist of digits" do
    sim_card = sim_cards(:typical)

    sim_card.puk_code = 123456
    assert sim_card.valid?

    sim_card.puk_code = 'abcd'
    assert sim_card.invalid?
  end

end
