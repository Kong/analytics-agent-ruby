require 'apianalytics/frameworks/rack'

module ApiAnalytics::Frameworks
  class Rails < Rack

    def initialize(app, options = {})
      @app = app
      @service_token = options[:service_token]
      @send_body = options[:send_body] || false
      host = options[:host] || 'socket.apianalytics.com:5000'

      ApiAnalytics::Capture.setOptions(host: 'tcp://' + host)
    end

    def call(env)
      startedDateTime = Time.now
      status, headers, body = @app.call(env)

      record_entry startedDateTime, env, {
        :status => status,
        :headers => headers,
        :body => [body.body()]
      }

      [status, headers, body]
    end

  end
end
