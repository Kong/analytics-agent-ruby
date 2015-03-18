gem 'sinatra'
require 'sinatra'
require 'helper'
require 'apianalytics/sinatra'
require 'rack'

class TestSinatra < MiniTest::Test

  def setup
    @zmq_ctx = ZMQ::Context.create(1)
    @zmq_socket = @zmq_ctx.socket(ZMQ::PULL)
    @zmq_socket.connect('tcp://127.0.0.1:2200')
  end

  def teardown
    @zmq_socket.close
    @zmq_ctx.terminate
  end

  class TestApp < Sinatra::Base
    extend ApiAnalytics::Sinatra

    apianalytics! 'MY-API-KEY', host: 'localhost:2200'

    get('/') { 'Test Endpoint' }
  end

  # def test_should_send_alf
  #   results = false

  #   zmq_pull_once @zmq_socket do |message|
  #     print message
  #     assert message
  #   end

  #   sleep 0.1

  #   request = Rack::MockRequest.new(TestApp)
  #   response = request.get('/')

  #   if results
  #     print 'did we get here?'
  #   else
  #     flunk 'Did not get ALF'
  #   end
  # end


  # describe 'sinatra' do

  #   before :suite do
  #     print 'before sinatra'
  #   end

  #   should 'test sinatra' do
  #     flunk "hey buddy, you should probably rename this file and start testing for real"
  #   end

  #   should 'test sinatra again' do
  #     flunk "hey buddy, you should probably rename this file and start testing for real"
  #   end

  # end

end
