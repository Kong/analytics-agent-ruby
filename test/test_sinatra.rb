gem 'sinatra'
require 'sinatra'
require 'helper'
require 'apianalytics/frameworks/sinatra'
require 'rack'

class TestSinatra < MiniTest::Test
  @zmq_pull = nil

  # Test Sinatra App
  class TestApp < Sinatra::Base
    extend ApiAnalytics::Frameworks::Sinatra

    apianalytics! 'MY-API-KEY', '127.0.0.1:2200'

    get('/') { 'Test Endpoint' }
  end

  def setup
    # Create our socket server
    @zmq_pull = zmq_pull_socket('tcp://127.0.0.1:2200')

    # Connect to socket server
    ApiAnalytics::Capture.connect('tcp://127.0.0.1:2200')
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close
  end

  should 'send ALF on request' do
    results = false

    zmq_pull_once @zmq_pull do |message|
      results = true
    end

    sleep 0.05

    request = Rack::MockRequest.new(TestApp)
    response = request.get('/')

    sleep 0.05

    assert results
  end

end
