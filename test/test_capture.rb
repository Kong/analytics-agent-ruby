class TestCapture < MiniTest::Test

  def setup
    ApiAnalytics::Capture.bind_socket 'tcp://localhost:2200'

    @zmq_ctx = ZMQ::Context.create(1)
    @zmq_socket = @zmq_ctx.socket(ZMQ::PULL)
    @zmq_socket.connect('tcp://127.0.0.1:2200')
  end

  def teardown
    ApiAnalytics::Capture.destroy_socket

    @zmq_socket.close
    @zmq_ctx.terminate
  end

  should 'create bound socket' do
    assert ApiAnalytics::Capture.socket != nil
  end

  # should 'send ALF' do
  #   fakeEntry = 'test'
  #   ApiAnalytics::Capture.record! fakeEntry
  # end

end
