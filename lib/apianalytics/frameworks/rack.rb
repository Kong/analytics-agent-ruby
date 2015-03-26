require 'apianalytics/capture'
require 'time'
require 'socket'
require 'rack/utils'

# Hack
def status_code(status)
  Rack::Utils::HTTP_STATUS_CODES[status] || ''
end

def header_hash(headers)
  Rack::Utils::HeaderHash.new.merge(headers)
end

module ApiAnalytics::Frameworks
  class Rack

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

      if body.respond_to? :to_str
        body = [body.to_str]
      elsif body.respond_to?(:each)
        # do nothing
      elsif body.respond_to?(:body)
        body = [body.body]
      else
        raise TypeError, "stringable or iterable required"
      end

      record_entry startedDateTime, env, {
        :status => status,
        :headers => header_hash(headers),
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

    def request_content_size(request)
      if request['HTTP_CONTENT_LENGTH']
        request['HTTP_CONTENT_LENGTH'].to_i
      else
        request['rack.input'].size
      end
    end

    def response_headers(response)
      response[:headers].map { |k,v| {name: k, value: v} }
    end

    def response_headers_size(response)
      # HTTP/1.1 {STATUS} {STATUS_TEXT} = 10 extra characters
      first_line = response[:status].to_s.length + status_code(response[:status]).length + 10

      # {KEY}: {VALUE}\n\r
      header_fields = response[:headers].map { |k,v| k.length + v.bytesize + 4 }
        .inject(0) { |sum,v| sum + v }

      return first_line + header_fields
    end

    def response_content_size(response)
      if response[:headers]['Content-Length']
        response[:headers]['Content-Length'].to_i
      else
        response[:body].inject(0) { |sum, b| sum + b.bytesize }
      end
    end

    def record_entry(startedDateTime, request, response)
      time = Time.now - startedDateTime
      alf = ApiAnalytics::Message::Alf.new @service_token

      req_headers_size = request_header_size(request)
      req_content_size = request_content_size(request)

      res_headers_size = response_headers_size(response)
      res_content_size = response_content_size(response)

      entry = {
        startedDateTime: startedDateTime.iso8601,
        serverIpAddress: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address,
        request: {
          method: request['REQUEST_METHOD'],
          url: url(request),
          httpVersion: 'HTTP/1.1', # not available, default http/1.1
          queryString: request_query_string(request),
          headers: request_headers(request),
          headersSize: req_headers_size,
          content: {
            size: req_content_size,
            mimeType: request['HTTP_CONTENT_TYPE'] || 'application/octet-stream'
          },
          bodySize: req_headers_size + req_content_size
        },
        response: {
          status: response[:status],
          statusText: status_code(response[:status]),
          httpVersion: 'HTTP/1.1', # not available, default http/1.1
          headers: response_headers(response),
          headersSize: res_headers_size,
          content: {
            size: res_content_size,
            mimeType: response[:headers]['Content-Type'] || 'application/octet-stream'
          },
          bodySize: res_headers_size + res_content_size
        },
        timings: {
          send: 0,
          wait: (time * 1000).to_i,
          receive: 0,
        }
      }

      if @send_body
        require 'base64'
        entry[:request][:content][:encoding] = 'base64'
        request['rack.input'].rewind
        entry[:request][:content][:text] = Base64.strict_encode64(request['rack.input'].read)

        entry[:response][:content][:encoding] = 'base64'
        entry[:response][:content][:text] = Base64.strict_encode64(response[:body].join())
      end

      alf.add_entry entry
      ApiAnalytics::Capture.record! alf
    end

  end
end
