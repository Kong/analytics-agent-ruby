require 'sinatra/base'
require 'apianalytics/frameworks/rack'
require 'time'
require 'socket'
require 'json'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(service_token, options = {})
      host = options[:host] || 'socket.apianalytics.com:5000'
      use ApiAnalytics::Frameworks::Rack, service_token: service_token, host: host
    end

  end
end
