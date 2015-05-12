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

  def with_env(env)
    old_env = {}
    env.each { |k, v| old_env[k], ENV[k] = ENV[k], v.to_s }
    yield
  ensure
    old_env.each { |k,v| ENV[k] = v }
  end

  def test_ready
    assert with_socket('READY=1') {
      SystemdDaemon::Notify.ready
    }
  end

  def test_watchdog_is_not_enabled
    assert_equal false, SystemdDaemon::Notify.watchdog_timer
    assert_equal false, SystemdDaemon::Notify.watchdog?
  end

  def test_watchdog_is_enabled
    with_env('WATCHDOG_USEC' => '5000', 'WATCHDOG_PID' => $$) {
      assert_equal 5000, SystemdDaemon::Notify.watchdog_timer
      assert_equal true, SystemdDaemon::Notify.watchdog?
    }
  end
end
