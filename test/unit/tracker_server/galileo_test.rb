require 'test_helper'
require 'tracker_server/galileo'

module TrackerServer
  class Galileo
    def initialize(port)
      # do nothing
    end

    def logger
      # do nothing
    end
  end
end

class TrackerServer::GalileoTest < ActiveSupport::TestCase

  def setup
    @server = TrackerServer::Galileo.new(1234)
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
    assert_equal(53.612224, packet[:latitude])
    assert(packet.key? :longitude)
    assert_equal(86.890424, packet[:longitude])
  end

  test "parse packet speed tag" do
    packet = @server.parse_packet("\x33\x5C\x00\x48\x08")
    assert(packet.key? :speed)
    assert_equal(9.2, packet[:speed])
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
    assert_equal(25.5, packet[:hdop])
  end

  test "parse packet status0 tag" do
    packet = @server.parse_packet("\x40\x00\x00")
    assert(packet.key? :status)
    assert_equal(0, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status1 tag" do
    packet = @server.parse_packet("\x40\x01\x00")
    assert(packet.key? :status)
    assert_equal(1, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(true, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status2 tag" do
    packet = @server.parse_packet("\x40\x02\x00")
    assert(packet.key? :status)
    assert_equal(2, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(true, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status3 tag" do
    packet = @server.parse_packet("\x40\x20\x00")
    assert(packet.key? :status)
    assert_equal(32, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(true, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status4 tag" do
    packet = @server.parse_packet("\x40\x40\x00")
    assert(packet.key? :status)
    assert_equal(64, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(false, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status5 tag" do
    packet = @server.parse_packet("\x40\x80\x00")
    assert(packet.key? :status)
    assert_equal(128, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(true, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status6 tag" do
    packet = @server.parse_packet("\x40\x00\x01")
    assert(packet.key? :status)
    assert_equal(256, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(true, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status7 tag" do
    packet = @server.parse_packet("\x40\x00\x02")
    assert(packet.key? :status)
    assert_equal(512, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(true, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status8 tag" do
    packet = @server.parse_packet("\x40\x00\x04")
    assert(packet.key? :status)
    assert_equal(1024, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(true, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status9 tag" do
    packet = @server.parse_packet("\x40\x00\x08")
    assert(packet.key? :status)
    assert_equal(2048, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(true, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status10 tag" do
    packet = @server.parse_packet("\x40\x00\x30")
    assert(packet.key? :status)
    assert_equal(12288, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(3, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status11 tag" do
    packet = @server.parse_packet("\x40\x00\x40")
    assert(packet.key? :status)
    assert_equal(16384, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(true, packet[:alarm_mode])
    assert(packet.key? :alarm)
    assert_equal(false, packet[:alarm])
  end

  test "parse packet status12 tag" do
    packet = @server.parse_packet("\x40\x00\x80")
    assert(packet.key? :status)
    assert_equal(32768, packet[:status])
    assert(packet.key? :sens_moving)
    assert_equal(false, packet[:sens_moving])
    assert(packet.key? :bad_angle)
    assert_equal(false, packet[:bad_angle])
    assert(packet.key? :int_power_low)
    assert_equal(false, packet[:int_power_low])
    assert(packet.key? :gps_antenna)
    assert_equal(true, packet[:gps_antenna])
    assert(packet.key? :int_bus_power_low)
    assert_equal(false, packet[:int_bus_power_low])
    assert(packet.key? :ext_power_low)
    assert_equal(false, packet[:ext_power_low])
    assert(packet.key? :enigne_on)
    assert_equal(false, packet[:enigne_on])
    assert(packet.key? :sens_hit)
    assert_equal(false, packet[:sens_hit])
    assert(packet.key? :glonass)
    assert_equal(false, packet[:glonass])
    assert(packet.key? :signal)
    assert_equal(0, packet[:signal])
    assert(packet.key? :alarm_mode)
    assert_equal(false, packet[:alarm_mode])
    assert(packet.key? :alarm)
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

  test "parse packet power_input_0 tag" do
    packet = @server.parse_packet("\x50\x5A\x5A")
    assert(packet.key? :power_input_0)
    assert_equal(23130, packet[:power_input_0])
  end

  test "parse packet power_input_1 tag" do
    packet = @server.parse_packet("\x51\x5A\x5A")
    assert(packet.key? :power_input_1)
    assert_equal(23130, packet[:power_input_1])
  end

  test "parse packet power_input_2 tag" do
    packet = @server.parse_packet("\x52\x5A\x5A")
    assert(packet.key? :power_input_2)
    assert_equal(23130, packet[:power_input_2])
  end

  test "parse packet power_input_3 tag" do
    packet = @server.parse_packet("\x53\x5A\x5A")
    assert(packet.key? :power_input_3)
    assert_equal(23130, packet[:power_input_3])
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
    packet = @server.parse_packet("\x70\x00\xD8")
    assert(packet.key? :thermometer_0)
    assert_equal(23130, packet[:thermometer_0])
  end

  test "parse packet thermometer_1 tag" do
    packet = @server.parse_packet("\x71\x01\xD8")
    assert(packet.key? :thermometer_1)
    assert_equal(23130, packet[:thermometer_1])
  end

  test "parse packet thermometer_2 tag" do
    packet = @server.parse_packet("\x72\x02\xD8")
    assert(packet.key? :thermometer_2)
    assert_equal(23130, packet[:thermometer_2])
  end

  test "parse packet thermometer_3 tag" do
    packet = @server.parse_packet("\x73\x03\xD8")
    assert(packet.key? :thermometer_3)
    assert_equal(23130, packet[:thermometer_3])
  end

  test "parse packet thermometer_4 tag" do
    packet = @server.parse_packet("\x74\x04\xD8")
    assert(packet.key? :thermometer_4)
    assert_equal(23130, packet[:thermometer_4])
  end

  test "parse packet thermometer_5 tag" do
    packet = @server.parse_packet("\x75\x05\xD8")
    assert(packet.key? :thermometer_5)
    assert_equal(23130, packet[:thermometer_5])
  end

  test "parse packet thermometer_6 tag" do
    packet = @server.parse_packet("\x76\x06\xD8")
    assert(packet.key? :thermometer_6)
    assert_equal(23130, packet[:thermometer_6])
  end

  test "parse packet thermometer_7 tag" do
    packet = @server.parse_packet("\x77\x07\xD8")
    assert(packet.key? :thermometer_7)
    assert_equal(23130, packet[:thermometer_7])
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

  test "parse packet can8bitr0 tag" do
    packet = @server.parse_packet("\xC4\xA5")
    assert(packet.key? :can8bitr0)
    assert_equal(165, packet[:can8bitr0])
  end

  test "parse packet can8bitr1 tag" do
    packet = @server.parse_packet("\xC5\xA5")
    assert(packet.key? :can8bitr1)
    assert_equal(165, packet[:can8bitr1])
  end

  test "parse packet can8bitr2 tag" do
    packet = @server.parse_packet("\xC6\xA5")
    assert(packet.key? :can8bitr2)
    assert_equal(165, packet[:can8bitr2])
  end

  test "parse packet can8bitr3 tag" do
    packet = @server.parse_packet("\xC7\xA5")
    assert(packet.key? :can8bitr3)
    assert_equal(165, packet[:can8bitr3])
  end

  test "parse packet can8bitr4 tag" do
    packet = @server.parse_packet("\xC8\xA5")
    assert(packet.key? :can8bitr4)
    assert_equal(165, packet[:can8bitr4])
  end

  test "parse packet can8bitr5 tag" do
    packet = @server.parse_packet("\xC9\xA5")
    assert(packet.key? :can8bitr5)
    assert_equal(165, packet[:can8bitr5])
  end

  test "parse packet can8bitr6 tag" do
    packet = @server.parse_packet("\xCA\xA5")
    assert(packet.key? :can8bitr6)
    assert_equal(165, packet[:can8bitr6])
  end

  test "parse packet can8bitr7 tag" do
    packet = @server.parse_packet("\xCB\xA5")
    assert(packet.key? :can8bitr7)
    assert_equal(165, packet[:can8bitr7])
  end

  test "parse packet can8bitr8 tag" do
    packet = @server.parse_packet("\xCC\xA5")
    assert(packet.key? :can8bitr8)
    assert_equal(165, packet[:can8bitr8])
  end

  test "parse packet can8bitr9 tag" do
    packet = @server.parse_packet("\xCD\xA5")
    assert(packet.key? :can8bitr9)
    assert_equal(165, packet[:can8bitr9])
  end

  test "parse packet can8bitr10 tag" do
    packet = @server.parse_packet("\xCE\xA5")
    assert(packet.key? :can8bitr10)
    assert_equal(165, packet[:can8bitr10])
  end

  test "parse packet can8bitr11 tag" do
    packet = @server.parse_packet("\xCF\xA5")
    assert(packet.key? :can8bitr11)
    assert_equal(165, packet[:can8bitr11])
  end

  test "parse packet can8bitr12 tag" do
    packet = @server.parse_packet("\xD0\xA5")
    assert(packet.key? :can8bitr12)
    assert_equal(165, packet[:can8bitr12])
  end

  test "parse packet can8bitr13 tag" do
    packet = @server.parse_packet("\xD1\xA5")
    assert(packet.key? :can8bitr13)
    assert_equal(165, packet[:can8bitr13])
  end

  test "parse packet can8bitr14 tag" do
    packet = @server.parse_packet("\xD2\xA5")
    assert(packet.key? :can8bitr14)
    assert_equal(165, packet[:can8bitr14])
  end

  test "parse packet can8bitr15 tag" do
    packet = @server.parse_packet("\xD3\xA5")
    assert(packet.key? :can8bitr15)
    assert_equal(165, packet[:can8bitr15])
  end

  test "parse packet can8bitr16 tag" do
    packet = @server.parse_packet("\xD4\xA5")
    assert(packet.key? :can8bitr16)
    assert_equal(165, packet[:can8bitr16])
  end

  test "parse packet can8bitr17 tag" do
    packet = @server.parse_packet("\xD5\xA5")
    assert(packet.key? :can8bitr17)
    assert_equal(165, packet[:can8bitr17])
  end

  test "parse packet can16bitr0 tag" do
    packet = @server.parse_packet("\xD6\x5A\x5A")
    assert(packet.key? :can16bitr0)
    assert_equal(23130, packet[:can16bitr0])
  end

  test "parse packet can16bitr1 tag" do
    packet = @server.parse_packet("\xD7\x5A\x5A")
    assert(packet.key? :can16bitr1)
    assert_equal(23130, packet[:can16bitr1])
  end

  test "parse packet can16bitr2 tag" do
    packet = @server.parse_packet("\xD8\x5A\x5A")
    assert(packet.key? :can16bitr2)
    assert_equal(23130, packet[:can16bitr2])
  end

  test "parse packet can16bitr3 tag" do
    packet = @server.parse_packet("\xD9\x5A\x5A")
    assert(packet.key? :can16bitr3)
    assert_equal(23130, packet[:can16bitr3])
  end

  test "parse packet can16bitr4 tag" do
    packet = @server.parse_packet("\xDA\x5A\x5A")
    assert(packet.key? :can16bitr4)
    assert_equal(23130, packet[:can16bitr4])
  end

  test "parse packet can32bitr0 tag" do
    packet = @server.parse_packet("\xDB\x01\x02\x03\x04")
    assert(packet.key? :can32bitr0)
    assert_equal(67305985, packet[:can32bitr0])
  end

  test "parse packet can32bitr1 tag" do
    packet = @server.parse_packet("\xDC\x01\x02\x03\x04")
    assert(packet.key? :can32bitr1)
    assert_equal(67305985, packet[:can32bitr1])
  end

  test "parse packet can32bitr2 tag" do
    packet = @server.parse_packet("\xDD\x01\x02\x03\x04")
    assert(packet.key? :can32bitr2)
    assert_equal(67305985, packet[:can32bitr2])
  end

  test "parse packet can32bitr3 tag" do
    packet = @server.parse_packet("\xDE\x01\x02\x03\x04")
    assert(packet.key? :can32bitr3)
    assert_equal(67305985, packet[:can32bitr3])
  end

  test "parse packet can32bitr4 tag" do
    packet = @server.parse_packet("\xDF\x01\x02\x03\x04")
    assert(packet.key? :can32bitr4)
    assert_equal(67305985, packet[:can32bitr4])
  end

end
