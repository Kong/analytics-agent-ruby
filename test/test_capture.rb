require 'helper'
require 'json'

class TestCapture < MiniTest::Test

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket(@@host)
  end

  def teardown
    MashapeAnalytics::Capture.disconnect
    @zmq_pull.close
  end

  should 'send ALF' do
    alf = MashapeAnalytics::Message::Alf.new 'SERVICE-TOKEN', 'ENVIRONMENT'
    MashapeAnalytics::Capture.record! alf

    version, message = @zmq_pull.recv().split(' ', 2)

    alf = JSON.parse(message)

    assert_ruby_agent alf
    assert_equal 'alf_1.0.0', version
  end

end
