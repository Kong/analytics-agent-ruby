require 'rbczmq'
require 'rack'
require 'sinatra'

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

  ApiAnalytics::Capture.setOptions(host: @@host) # Set default host

  def zmq_pull_socket(host)
    pull_socket = ApiAnalytics::Capture.context.socket(:PULL)
    pull_socket.bind(host)

    return pull_socket
  end

  def assert_ruby_agent(alf_json)
    assert_equal 'mashape-analytics-agent-ruby', alf_json['har']['log']['creator']['name']
  end

  def assert_entry_request(entry_json, method, url)
    assert_equal method, entry_json['request']['method']
    assert_equal url, entry_json['request']['url']
  end

  def assert_entry_request_content(entry_json, encoding, text)
    assert_equal encoding, entry_json['request']['content']['encoding']
    assert_equal text, entry_json['request']['content']['text']
  end

  def assert_entry_response(entry_json, status, bodySize)
    assert_equal status, entry_json['response']['status']
    assert_equal bodySize, entry_json['response']['bodySize']
  end

  def assert_entry_response_content(entry_json, encoding, text)
    assert_equal encoding, entry_json['response']['content']['encoding']
    assert_equal text, entry_json['response']['content']['text']
  end

end
