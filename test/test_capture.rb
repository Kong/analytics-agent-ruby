class TestCapture < MiniTest::Test
  @@host = 'tcp://127.0.0.1:2200'

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

  # should 'create bound socket' do
  #   assert ApiAnalytics::Capture.socket != nil
  # end

  should 'send ALF' do
    message = ''

    zmq_pull_once @zmq_pull do |msg|
      message = msg
    end

    fakeEntry = ApiAnalytics::Message::Entry.new
    ApiAnalytics::Capture.record! fakeEntry

    sleep 0.01

    assert_equal '{}', message
  end

end
