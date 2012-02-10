require 'test_helper'
require 'tracker_server/galileo'

module TrackerServer
  class Galileo
    def initialize(port)
      # do nothing
    end

    def logger
      return @logger if @logger
      @logger = TrackerServer::Logger.new(STDERR)
    end
  end
end

class TrackerServer::GalileoTest < ActiveSupport::TestCase

  def setup
    @server = TrackerServer::Galileo.new(1234)
  end

  def validate_status_props(packet)
    props = %w{ status sens_moving bad_angle int_power_low
      gps_antenna int_bus_power_low ext_power_low
      enigne_on sens_hit glonass signal alarm_mode alarm }
    props.each{ |key| assert(packet.key?(key.to_sym), "key #{key} is absent") }
  end

  test "get packet size" do
    assert_equal(66, @server.get_packet_size("\x42\x00"))
    assert_equal(552, @server.get_packet_size("\x28\x02"))
  end

  test "get packet size (with not sent data flag)" do
    assert_equal(66, @server.get_packet_size("\x42\x80"))
  end

  test "parse packet with unknown tag" do
    packet = @server.parse_packet("\x05")
    assert(packet.empty?)
  end

  test "parse packet hardware version tag" do
    packet = @server.parse_packet("\x01\x0A")
    assert(packet.key? :hardware_version)
    assert_equal(10, packet[:hardware_version])
  end

  test "parse packet firmware version tag" do
    packet = @server.parse_packet("\x02\x4d")
    assert(packet.key? :firmware_version)
    assert_equal(77, packet[:firmware_version])
  end

  test "parse packet imei tag" do
    packet = @server.parse_packet("\x03123456789012345")
    assert(packet.key? :imei)
    assert_equal("123456789012345", packet[:imei])
  end

  test "parse packet device id tag" do
    packet = @server.parse_packet("\x04\xBE\xB1")
    assert(packet.key? :device_id)
    assert_equal(45502, packet[:device_id])
  end

  test "parse packet record id tag" do
    packet = @server.parse_packet("\x10\x48\xA5")
    assert(packet.key? :record_id)
    assert_equal(42312, packet[:record_id])
  end

  test "parse packet timestamp tag" do
    packet = @server.parse_packet("\x20\x87\x48\x09\x77")
    assert(packet.key? :timestamp)
    assert_equal(1997097095, packet[:timestamp])
  end

  test "parse packet coordinates tag" do
    packet = @server.parse_packet("\x30\x27\xC0\x0E\x32\x03\xB8\xD7\x2D\x05")
    assert(packet.key? :coors_valid)
    assert_equal(false, packet[:coors_valid])
    assert(packet.key? :satellites)
    assert_equal(7, packet[:satellites])
    assert(packet.key? :latitude)
    assert_in_delta(53.612224, packet[:latitude], 0.0000001)
    assert(packet.key? :longitude)
    assert_in_delta(86.890424, packet[:longitude], 0.0000001)
  end

  test "parse packet speed tag" do
    packet = @server.parse_packet("\x33\x5C\x00\x48\x08")
    assert(packet.key? :speed)
    assert_in_delta(9.2, packet[:speed], 0.01)
    assert(packet.key? :direction)
    assert_equal(212, packet[:direction])
  end

  test "parse packet height tag" do
    packet = @server.parse_packet("\x34\xFB\xFF")
    assert(packet.key? :height)
    assert_equal(-5, packet[:height])
  end

  test "parse packet hdop tag" do
    packet = @server.parse_packet("\x35\xFF")
    assert(packet.key? :hdop)
    assert_in_delta(25.5, packet[:hdop], 0.01)
  end

  test "parse packet status0 tag" do
    packet = @server.parse_packet("\x40\x00\x00")
    validate_status_props(packet)
    assert_equal(0, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status1 tag" do
    packet = @server.parse_packet("\x40\x01\x00")
    validate_status_props(packet)
    assert_equal(1, packet[:status])
    assert_equal(true, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status2 tag" do
    packet = @server.parse_packet("\x40\x02\x00")
    validate_status_props(packet)
    assert_equal(2, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(true, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status3 tag" do
    packet = @server.parse_packet("\x40\x20\x00")
    validate_status_props(packet)
    assert_equal(32, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(true, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status4 tag" do
    packet = @server.parse_packet("\x40\x40\x00")
    validate_status_props(packet)
    assert_equal(64, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(false, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status5 tag" do
    packet = @server.parse_packet("\x40\x80\x00")
    validate_status_props(packet)
    assert_equal(128, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(true, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status6 tag" do
    packet = @server.parse_packet("\x40\x00\x01")
    validate_status_props(packet)
    assert_equal(256, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(true, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status7 tag" do
    packet = @server.parse_packet("\x40\x00\x02")
    validate_status_props(packet)
    assert_equal(512, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(true, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status8 tag" do
    packet = @server.parse_packet("\x40\x00\x04")
    validate_status_props(packet)
    assert_equal(1024, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(true, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status9 tag" do
    packet = @server.parse_packet("\x40\x00\x08")
    validate_status_props(packet)
    assert_equal(2048, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(true, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status10 tag" do
    packet = @server.parse_packet("\x40\x00\x30")
    validate_status_props(packet)
    assert_equal(12288, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(3, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status11 tag" do
    packet = @server.parse_packet("\x40\x00\x40")
    validate_status_props(packet)
    assert_equal(16384, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(true, packet[:alarm_mode])
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status12 tag" do
    packet = @server.parse_packet("\x40\x00\x80")
    validate_status_props(packet)
    assert_equal(32768, packet[:status])
    assert_equal(false, packet[:sens_moving])
    assert_equal(false, packet[:bad_angle])
    assert_equal(false, packet[:int_power_low])
    assert_equal(true, packet[:gps_antenna])
    assert_equal(false, packet[:int_bus_power_low])
    assert_equal(false, packet[:ext_power_low])
    assert_equal(false, packet[:enigne_on])
    assert_equal(false, packet[:sens_hit])
    assert_equal(false, packet[:glonass])
    assert_equal(0, packet[:signal])
    assert_equal(false, packet[:alarm_mode])
    assert_equal(true, packet[:alarm])
  end

  test "parse packet int_power tag" do
    packet = @server.parse_packet("\x41\xC8\x32")
    assert(packet.key? :int_power)
    assert_equal(13000, packet[:int_power])
  end

  test "parse packet ext_power tag" do
    packet = @server.parse_packet("\x42\xC8\x32")
    assert(packet.key? :ext_power)
    assert_equal(13000, packet[:ext_power])
  end

  test "parse packet temperature tag" do
    packet = @server.parse_packet("\x43\xE2")
    assert(packet.key? :temperature)
    assert_equal(-30, packet[:temperature])
  end

  test "parse packet acceleration tag" do
    packet = @server.parse_packet("\x44\xAF\x21\x98\x15")
    assert(packet.key? :acceleration_x)
    assert_equal(431, packet[:acceleration_x])
    assert(packet.key? :acceleration_y)
    assert_equal(520, packet[:acceleration_y])
    assert(packet.key? :acceleration_z)
    assert_equal(345, packet[:acceleration_z])
  end

  test "parse packet output_statuses tag" do
    packet = @server.parse_packet("\x45\x5A\x5A")
    assert(packet.key? :output_statuses)
    assert_equal(23130, packet[:output_statuses])
  end

  test "parse packet input_statuses tag" do
    packet = @server.parse_packet("\x46\x5A\x5A")
    assert(packet.key? :input_statuses)
    assert_equal(23130, packet[:input_statuses])
  end

  test "parse packet power_input tags" do
    0.upto(3).each do |tag_index|
      packet = @server.parse_packet((0x50 + tag_index).chr + "\x5A\x5A")
      tag_key = "power_input_#{tag_index}".to_sym
      assert(packet.key?(tag_key), tag_key)
      assert_equal(23130, packet[tag_key], tag_key)
    end
  end

  test "parse packet rs232_0 tag" do
    packet = @server.parse_packet("\x58\x5A\x5A")
    assert(packet.key? :rs232_0)
    assert_equal(23130, packet[:rs232_0])
  end

  test "parse packet rs232_1 tag" do
    packet = @server.parse_packet("\x59\x5A\x5A")
    assert(packet.key? :rs232_1)
    assert_equal(23130, packet[:rs232_1])
  end

  test "parse packet thermometer_0 tag" do
    packet = @server.parse_packet("\x70\x00\x10")
    assert(packet.key? :thermometer_0)
    assert_equal(16, packet[:thermometer_0])
  end

  test "parse packet thermometers tags" do
    1.upto(7).each do |tag_index|
      packet = @server.parse_packet((0x70 + tag_index).chr + "\x01\xD8")
      tag_key = "thermometer_#{tag_index}".to_sym
      assert(packet.key?(tag_key), tag_key)
      assert_equal(-40, packet[tag_key], tag_key)
    end
  end

  test "parse packet ibutton tag" do
    packet = @server.parse_packet("\x90\x01\x02\x03\x04")
    assert(packet.key? :ibutton)
    assert_equal(67305985, packet[:ibutton])
  end

  test "parse packet fms_fuel_consumed tag" do
    packet = @server.parse_packet("\xC0\x01\x02\x03\x04")
    assert(packet.key? :fms_fuel_consumed)
    assert_equal(33652992.5, packet[:fms_fuel_consumed])
  end

  test "parse packet fms_fuel tag" do
    packet = @server.parse_packet("\xC1\xFA\x72\x50\x25")
    assert(packet.key? :fms_fuel)
    assert_equal(100, packet[:fms_fuel])
    assert(packet.key? :antifreeze)
    assert_equal(74, packet[:antifreeze])
    assert(packet.key? :eninge_rpm)
    assert_equal(1194, packet[:eninge_rpm])
  end

  test "parse packet fms_distance tag" do
    packet = @server.parse_packet("\xC2\x01\x02\x03\x04")
    assert(packet.key? :fms_distance)
    assert_equal(336529925, packet[:fms_distance])
  end

  test "parse packet can_b1 tag" do
    packet = @server.parse_packet("\xC3\x01\x02\x03\x04")
    assert(packet.key? :can_b1)
    assert_equal(67305985, packet[:can_b1])
  end

  test "parse packet can8bitr tags" do
    0.upto(17).each do |tag_index|
      packet = @server.parse_packet((0xC4 + tag_index).chr + "\xA5")
      tag_key = "can8bitr#{tag_index}".to_sym
      assert(packet.key?(tag_key), tag_key)
      assert_equal(165, packet[tag_key], tag_key)
    end
  end

  test "parse packet can16bitr tags" do
    0.upto(4).each do |tag_index|
      packet = @server.parse_packet((0xD6 + tag_index).chr + "\x5A\x5A")
      tag_key = "can16bitr#{tag_index}".to_sym
      assert(packet.key?(tag_key), tag_key)
      assert_equal(23130, packet[tag_key], tag_key)
    end 
  end

  test "parse packet can32bitr tags" do
    0.upto(4).each do |tag_index|
      packet = @server.parse_packet((0xDB + tag_index).chr + "\x01\x02\x03\x04")
      tag_key = "can32bitr#{tag_index}".to_sym
      assert(packet.key?(tag_key), tag_key)
      assert_equal(67305985, packet[tag_key], tag_key)
    end
  end

end
