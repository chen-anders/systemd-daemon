require 'helper'
require 'socket'

class TestSystemdDaemonNotify < Test::Unit::TestCase

  def with_socket(expected_data)
    notify_socket = "@test-systemd-daemon-#{$$}"
    ENV['NOTIFY_SOCKET'] = notify_socket
    s = Socket.new(:UNIX, :DGRAM, 0)
    s.bind(Addrinfo.unix(notify_socket.gsub('@', "\0")))

    yield

    s.recvmsg[0] == expected_data
  ensure
    s.close
  end

  def test_ready
    assert with_socket('READY=1') {
      SystemdDaemon::Notify.ready
    }
  end
end
