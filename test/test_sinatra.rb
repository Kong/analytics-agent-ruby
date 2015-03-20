require 'sinatra'
require 'helper'
require 'apianalytics/frameworks/sinatra'
require 'rack'
require 'json'

class TestSinatra < MiniTest::Test
  @zmq_pull = nil

  # Test Sinatra App
  class TestApp < Sinatra::Base
    register ApiAnalytics::Frameworks::Sinatra

    apianalytics! 'MY-API-KEY', '127.0.0.1:2200'

    get('/get') { 'GET Endpoint' }
    post('/post') { 'POST Endpoint' }
  end

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

  should 'send ALF on GET /get request' do
    request = Rack::MockRequest.new(TestApp)
    response = request.get('/get')

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'GET', 'http://example.org/get'
    assert_entry_response entry, 200, 12
  end

  should 'send ALF on POST /post request' do
    request = Rack::MockRequest.new(TestApp)
    response = request.post('/post')

    message = @zmq_pull.recv
    alf = JSON.parse(message)

    assert_ruby_agent alf

    entry = alf['har']['log']['entries'].first
    assert_entry_request entry, 'POST', 'http://example.org/post'
    assert_entry_response entry, 200, 13
  end


end
