require 'ffi-rzmq'
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
  Thread.abort_on_exception = true

  @@zmq_context = ZMQ::Context.create(1)

  def zmq_pull_socket(host)
    pull_socket = @@zmq_context.socket(ZMQ::PULL)
    pull_socket.setsockopt(ZMQ::LINGER, 0)
    rc = pull_socket.bind(host)

    if not ZMQ::Util.resultcode_ok?(rc)
      STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
      caller(1).each { |callstack| STDERR.puts(callstack) }
    end

    return pull_socket
  end

  def zmq_pull_once(socket)
    Thread.new do
      message = ''
      rc = 0

      rc = socket.recv_string(message)
      if not ZMQ::Util.resultcode_ok?(rc)
        STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
        caller(1).each { |callstack| STDERR.puts(callstack) }
        Thread.exit
      end

      yield message
    end
  end

end
