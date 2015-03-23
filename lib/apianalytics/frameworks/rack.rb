require 'sinatra/base'
require 'apianalytics/capture'
require 'time'
require 'socket'
require 'json'

module ApiAnalytics::Frameworks
  class Rack

    def initialize(app, options)
      @app = app
      @service_token = options[:service_token]

      host = options[:host] or 'socket.apianalytics.com:5000'
      ApiAnalytics::Capture.connect('tcp://' + host)
    end

    def call(env)
      startedDateTime = Time.now
      status, headers, body = @app.call(env)

      dup._record_alf startedDateTime, request, {
        :status => status,
        :headers => headers,
        :body => body
      }

      [status, headers, body]
    end

    def _record_alf(startedDateTime, request, response)
        time = Time.now - startedDateTime

        alf = ApiAnalytics::Message::Alf.new service_token

        entry = {
          startedDateTime: @startedDateTime.iso8601,
          serverIpAddress: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address,
          request: {
            method: request.request_method,
            url: request.url,
            httpVersion: 'HTTP/1.1', # not available in sinatra, default http/1.1
            # queryString:
            # headers:
            # headersSize:
            # content:
            bodySize: request.content_length.to_i
          },
          response: {
            status: response.status,
            statusText: '',
            httpVersion: 'HTTP/1.1', # not available in sinatra, default http/1.1
            # headers:
            # headersSize:
            # content:
            bodySize: response.body.inject(0) { |sum, b| sum + b.bytesize }
          },
          timings: {
            send: 0,
            wait: ((Time.now - @startedDateTime) * 1000).to_i,
            receive: 0,
          }
        }
        # puts JSON.pretty_generate(request.query_string)
        # puts JSON.pretty_generate(entry)

        alf.add_entry entry

        ApiAnalytics::Capture.record! alf
    end

    def apianalytics!(service_token, host='socket.apianalytics.com:5000')

      before do
      end

      after do

      end
    end

  end
end
