require 'helper'
require 'apianalytics/frameworks/rack'
require 'rack'

class TestRack < MiniTest::Test
  def app
    app = proc{[200,{},['Hello, world.']]}
    stack = ApiAnalytics::Frameworks::Rack.new app, service_token: 'SERVICE-TOKEN', host: '127.0.0.1:2200'
    Rack::MockRequest.new(stack)
  end

  # let(:app) { proc{[200,{},['Hello, world.']]} }
  # let(:stack) { ApiAnalytics::Frameworks::Rack.new app, service_token: 'SERVICE-TOKEN', host: '127.0.0.1:2200' }

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket('tcp://127.0.0.1:2200')

    # Connect to socket server
    ApiAnalytics::Capture.connect('tcp://127.0.0.1:2200')
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close if @zmq_pull != nil
  end

  should 'send ALF on GET /get?query=test request' do
    # request = Rack::MockRequest.new(subject.new)
    response = app().get('/get?query=test')

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'GET', 'http://example.org/get'
    assert_entry_response entry, 200, 12
  end


  # describe '#call' do
  #   it 'responds with not acceptable if the accepted response format is other than JSON' do
  #     request = Rack::MockRequest.new(subject.new)
  #     response = request.get('/', {'HTTP_ACCEPT' => 'text/html'})

  #     response.status.must_equal 406
  #   end

  #   it 'does nothing otherwise' do
  #     app_mock = MiniTest::Mock.new
  #     app_mock.expect(:call, [200, {}, ['']], [Hash])
  #     request = Rack::MockRequest.new(subject.new(app_mock))
  #     response = request.get('/', {'HTTP_ACCEPT' => '*/*'})

  #     app_mock.verify
  #   end
  # end


  # def setup
  #   # Create our socket server
  #   @zmq_pull = zmq_pull_socket('tcp://127.0.0.1:2200')

  #   # Connect to socket server
  #   ApiAnalytics::Capture.connect('tcp://127.0.0.1:2200')
  # end

  # def teardown
  #   ApiAnalytics::Capture.disconnect
  #   @zmq_pull.close if @zmq_pull != nil
  # end

end
