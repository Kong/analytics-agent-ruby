require 'sinatra/base'
require 'mashape-analytics/frameworks/rack'
require 'time'
require 'socket'
require 'json'

module MashapeAnalytics::Frameworks
  module Sinatra

    def mashapeAnalytics!(service_token, options = {})
      options[:service_token] = service_token
      use MashapeAnalytics::Frameworks::Rack, options
    end

  end
end
