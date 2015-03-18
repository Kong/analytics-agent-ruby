gem 'sinatra'
require 'sinatra'
require 'helper'
require 'apianalytics/frameworks/sinatra'
require 'rack'

class TestSinatra < MiniTest::Test

  # Test Sinatra App
  class TestApp < Sinatra::Base
    extend ApiAnalytics::Frameworks::Sinatra

    apianalytics! 'MY-API-KEY', host: '127.0.0.1:2200'

    get('/') { 'Test Endpoint' }
  end

  def setup
    # Create our socket server
    @zmq_ctx = zmq_context
    @zmq_pull = zmq_pull_socket(@zmq_ctx, 'tcp://127.0.0.1:2200')

    # Connect to socket server
    ApiAnalytics::Capture.connect('tcp://127.0.0.2:2200')
  end

  def teardown
    ApiAnalytics::Capture.disconnect
    @zmq_pull.close
    @zmq_ctx.terminate
  end

  # should 'send ALF on request' do
  #   results = false

  #   request = Rack::MockRequest.new(TestApp)
  #   response = request.get('/')

  #   sleep 1
  #   zmq_pull_once @zmq_pull do |message|
  #     print message
  #     assert message
  #     results = true
  #   end



  #   if results
  #     print 'SUCCESS!'
  #   else
  #     print 'FAILURE!'
  #   end
  # end

end
