require 'apianalytics/capture'
require 'time'
require 'socket'
require 'rack/utils'

# Hack
def status_code(status)
  Rack::Utils::HTTP_STATUS_CODES[status] || ''
end

module ApiAnalytics::Frameworks
  class Rack

    def initialize(app, options)
      @app = app
      @service_token = options[:service_token]
      host = options[:host] || 'socket.apianalytics.com:5000'
      ApiAnalytics::Capture.connect('tcp://' + host)
    end

    def call(env)
      startedDateTime = Time.now
      status, headers, body = @app.call(env)

      record_alf startedDateTime, env, {
        :status => status,
        :headers => headers,
        :body => body
      }

      [status, headers, body]
    end

    def host(request)
      if forwarded = request['HTTP_X_FORWARDED_HOST']
        forwarded.split(/,\s?/).last
      elsif (request['rack.url_scheme'] == 'http' and request['SERVER_PORT'] == '80') or (request['rack.url_scheme'] == 'https' and request['SERVER_PORT'] == '443')
        request['HTTP_HOST'] || "#{request['SERVER_NAME'] || request['SERVER_ADDR']}"
      else
        request['HTTP_HOST'] || "#{request['SERVER_NAME'] || request['SERVER_ADDR']}:#{request['SERVER_PORT']}"
      end
    end


    def url(request)
      "#{request['rack.url_scheme']}://#{host(request)}#{request['PATH_INFO']}"
    end

    def request_headers(request)
      request.select {|k,v| k.start_with? 'HTTP_'}
        .map { |k,v| {name: k.sub(/^HTTP_/, '').sub(/_/, '-'), value: v} }
    end

    def request_header_size(request)
      # {METHOD} {URL} HTTP/1.1\r\n = 12 extra characters for space between method and url, and ` HTTP/1.1\r\n`
      first_line = request['REQUEST_METHOD'].length + url(request).length + 12

      # {KEY}: {VALUE}\n\r = 4 extra characters for `: ` and `\n\r` minus `HTTP_` in the KEY is -1
      header_fields = request.select { |k,v| k.start_with? 'HTTP_' }
        .map { |k,v| k.length + v.bytesize - 1 }
        .inject(0) { |sum,v| sum + v }

      last_line = 2 # /r/n

      first_line + header_fields + last_line
    end

    def request_query_string(request)
      request['QUERY_STRING'].split('&')
        .map do |q|
          parts = q.split('=')
          {name: parts.first, value: parts.length > 1 ? parts.last : nil }
        end
    end

    def response_headers(response)
      response[:headers].map { |k,v| {name: k, value: v} }
    end

    def response_headers_size(response)
      # HTTP/1.1 {STATUS} {STATUS_TEXT} = 10 extra characters
      first_line = response[:status] + status_code(response[:status]) + 10
    end

    def record_alf(startedDateTime, request, response)
      time = Time.now - startedDateTime
      alf = ApiAnalytics::Message::Alf.new @service_token

      entry = {
        startedDateTime: startedDateTime.iso8601,
        serverIpAddress: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address,
        request: {
          method: request['REQUEST_METHOD'],
          url: url(request),
          httpVersion: 'HTTP/1.1', # not available, default http/1.1
          queryString: request_query_string(request),
          headers: request_headers(request),
          headersSize: request_header_size(request),
          # # content:
          bodySize: request['CONTENT_LENGTH'].to_i
        },
        response: {
          status: response[:status],
          statusText: status_code(response[:status]),
          httpVersion: 'HTTP/1.1', # not available, default http/1.1
          headers: response_headers(response),
          # headersSize:
          # content:
          bodySize: response[:body].inject(0) { |sum, b| sum + b.bytesize }
        },
        timings: {
          send: 0,
          wait: (time * 1000).to_i,
          receive: 0,
        }
      }

      alf.add_entry entry
      ApiAnalytics::Capture.record! alf
    end

  end
end
