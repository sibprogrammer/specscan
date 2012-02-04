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

end
