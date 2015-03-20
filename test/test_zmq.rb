class TestZmq < MiniTest::Test
  @zmq_ctx = nil
  @zmq_push = nil
  @zmq_pull = nil

  def setup
    host = 'tcp://127.0.0.1:2200'

    @zmq_pull = zmq_pull_socket host

    @zmq_push = ApiAnalytics::Capture.context.socket(:PUSH)
    rc = @zmq_push.connect(host)
  end

  def teardown
    @zmq_pull.close
    @zmq_push.close
  end

  should 'create push & pull socket' do
    @zmq_push.send 'test'
    message = @zmq_pull.recv

    assert_equal 'test', message
  end

end
