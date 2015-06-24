require 'rack'
require 'helper'

class TestRack < MiniTest::Test
  @send_body = false

  def app
    app = proc do
      sleep 0.05
      [200, {'CONTENT-TYPE' => 'application/json'}, ['{"messages": "Test Response"}']]
    end
    stack = MashapeAnalytics::Frameworks::Rack.new app, service_token: 'SERVICE-TOKEN', host: @@host, send_body: @send_body
    Rack::MockRequest.new(stack)
  end

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket(@@host)
  end

  def teardown
    MashapeAnalytics::Capture.disconnect
    @zmq_pull.close if @zmq_pull != nil
    @send_body = false
  end

  should 'send ALF on GET /get?foo=bar&empty request' do
    response = app.get('/get?foo=bar&empty', {'HTTP_ACCEPT' => 'application/json'})

    version, message = @zmq_pull.recv.split(' ', 2)
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'GET', 'http://example.org/get?foo=bar&empty'
    assert_entry_response entry, 200, 76
  end

  should 'send ALF on POST /post request' do
    response = app.post('/post', {'HTTP_ACCEPT' => 'application/json', input: 'test POST body'})

    version, message = @zmq_pull.recv.split(' ', 2)
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'POST', 'http://example.org/post'
    assert_entry_response entry, 200, 76
  end

  should 'send ALF with body on POST /post request' do
    @send_body = true
    response = app.post('/post', {'HTTP_ACCEPT' => 'application/json', input: 'test POST body'})

    version, message = @zmq_pull.recv.split(' ', 2)
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'POST', 'http://example.org/post'
    assert_entry_request_content entry, 'base64', 'dGVzdCBQT1NUIGJvZHk='

    assert_entry_response entry, 200, 76
    assert_entry_response_content entry, 'base64', 'eyJtZXNzYWdlcyI6ICJUZXN0IFJlc3BvbnNlIn0='
  end


end
