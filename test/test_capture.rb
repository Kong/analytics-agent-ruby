require 'helper'

class TestCapture < MiniTest::Test

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket(@@host)

    # Connect to socket server
    ApiAnalytics::Capture.connect(@@host)
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close
  end

  should 'create bound socket' do
    assert ApiAnalytics::Capture.socket != nil
  end

  should 'send ALF' do
    alf = ApiAnalytics::Message::Alf.new
    ApiAnalytics::Capture.record! alf

    message = @zmq_pull.recv

    assert_equal '{}', message
  end

end
