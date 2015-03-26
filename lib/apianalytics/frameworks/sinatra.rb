require 'sinatra/base'
require 'apianalytics/frameworks/rack'
require 'time'
require 'socket'
require 'json'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(service_token, options = {})
      host = options[:host] || 'socket.apianalytics.com:5000'
      send_body = options[:send_body] || false
      use ApiAnalytics::Frameworks::Rack, service_token: service_token, host: host, send_body: send_body
    end

  end
end
