require 'helper'
require 'json'

class TestCapture < MiniTest::Test

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket(@@host)
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close
  end

  should 'send ALF' do
    alf = ApiAnalytics::Message::Alf.new 'SERVICE-TOKEN'
    ApiAnalytics::Capture.record! alf

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf
  end

end
