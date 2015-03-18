class TestCapture < MiniTest::Test

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket('tcp://127.0.0.1:2200')

    # Connect to socket server
    ApiAnalytics::Capture.connect('tcp://127.0.0.2:2200')
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
      print "socket recv: #{msg}"
      message = msg
    end

    fakeEntry = ApiAnalytics::Message::Entry.new
    ApiAnalytics::Capture.record! fakeEntry

    sleep 0.01

    puts "test recv: #{message}"

    assert_equal '{}', message
  end

end
