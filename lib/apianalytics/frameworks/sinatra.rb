require 'sinatra/base'
require 'apianalytics/capture'
require 'time'
require 'socket'
require 'json'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(service_token, host='socket.apianalytics.com:5000')
      ApiAnalytics::Capture.connect('tcp://' + host)

      before do
        @startedDateTime = Time.now
      end

      after do
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
        # puts JSON.pretty_generate(request.params)
        # puts JSON.pretty_generate(entry)

        alf.add_entry entry

        ApiAnalytics::Capture.record! alf
      end
    end

  end
end
