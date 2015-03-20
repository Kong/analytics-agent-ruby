require 'rbczmq'
require 'rack'

require 'simplecov'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_adapter 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
# require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'apianalytics'

class MiniTest::Test
  @@host = 'tcp://127.0.0.1:2200'

  def zmq_pull_socket(host)
    pull_socket = ApiAnalytics::Capture.context.socket(:PULL)
    pull_socket.bind(host)

    return pull_socket
  end

  def assert_ruby_agent(alf_json)
    assert_equal 'Ruby Agent', alf_json['har']['log']['creator']['name']
  end

end
