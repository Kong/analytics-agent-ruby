require 'apianalytics/frameworks/rack'

module ApiAnalytics::Frameworks
  class Rails

    def initialize(app, options)
      @rack = ApiAnalytics::Frameworks::Rack.new(app, options)
    end

    def call(env)
      @rack.call(env)
    end

  end
end
