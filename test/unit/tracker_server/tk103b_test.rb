require 'test_helper'
require 'server/tracker/tk103b'

class Server::Tracker::Tk103b
  def initialize
    # do nothing
  end

  def logger
    return @logger if @logger
    @logger = Server::Logger.new('/dev/null')
  end
end

class Server::Tracker::Tk103bTest < ActiveSupport::TestCase

  def setup
    @server = Server::Tracker::Tk103b.new
  end

  test "get degrees for coors in minutes" do
    assert_in_delta(54.96245, @server.send(:coors_to_degrees, 5457.7470), 0.0001)
  end

  test "valid coors flag" do
    data = "imei:359587010124900,tracker,0809231929,13554900601,F,112909.397,A,2234.4669,N,11354.3287,E,0.11,;"
    packet = @server.send(:parse_packet, data)
    assert(packet[:coors_valid])
  end

  test "invalid coors flag if coors are zero" do
    data = "imei:359587010124900,tracker,0809231929,13554900601,F,112909.397,A,0,N,0,E,0.11,;"
    packet = @server.send(:parse_packet, data)
    assert_false(packet[:coors_valid])
  end

end

