require 'rack'
require 'helper'

class TestRack < MiniTest::Test
  def app
    app = proc do
      sleep 0.05
      [200, {'CONTENT-TYPE' => 'application/json'}, ['{"messages": "Test Response"}']]
    end
    stack = ApiAnalytics::Frameworks::Rack.new app, service_token: 'SERVICE-TOKEN', host: '127.0.0.1:2200'
    Rack::MockRequest.new(stack)
  end

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket(@@host)
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close
  end

  should 'send ALF on GET /get?foo=bar&empty request' do
    response = app.get('/get?foo=bar&empty', {'HTTP_ACCEPT' => 'application/json'})

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'GET', 'http://example.org/get'
    assert_entry_response entry, 200, 29
  end

  should 'send ALF on POST /post request' do
    response = app.post('/post', {'HTTP_ACCEPT' => 'application/json', input: 'test POST body'})

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'POST', 'http://example.org/post'
    assert_entry_response entry, 200, 29
  end

end
