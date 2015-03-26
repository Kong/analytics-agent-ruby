require 'apianalytics/frameworks/rack'

module ApiAnalytics::Frameworks
  class Rails
    include Rack

    def initialize(app, options)
      @app = app
      @service_token = options[:service_token]
      host = options[:host] || 'socket.apianalytics.com:5000'

      ApiAnalytics::Capture.connect('tcp://' + host)
    end

    def call(env)
      startedDateTime = Time.now
      status, headers, body = @app.call(env)

      record_alf @service_token, startedDateTime, env, {
        :status => status,
        :headers => headers,
        :body => body.body()
      }

      [status, headers, body]
    end

  end
end
