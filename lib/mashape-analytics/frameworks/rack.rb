require 'mashape-analytics/capture'
require 'time'
require 'socket'
require 'rack/utils'

def status_code(status)
  Rack::Utils::HTTP_STATUS_CODES[status] || ''
end

def header_hash(headers)
  Rack::Utils::HeaderHash.new.merge(headers)
end

module MashapeAnalytics::Frameworks
  class Rack

    def initialize(app, options = {})
      @app = app
      @service_token = options[:service_token]
      @environment = options[:environment] || ''
      @send_body = options[:send_body] || false
      host = options[:host] || 'tcp://socket.analytics.mashape.com:5500'

      MashapeAnalytics::Capture.setOptions(host: host)
    end

    def call(env)
      startedDateTime = Time.now
      status, headers, body = @app.call(env)

      if body.respond_to? :to_str
        response_body = [body.to_str]
      elsif body.respond_to?(:body)
        response_body = [body.body]
      elsif body.respond_to?(:each)
        response_body = body
      else
        raise TypeError, "stringable or iterable required"
      end

      record_alf startedDateTime, env, {
        :status => status,
        :headers => header_hash(headers),
        :body => response_body
      }

      [status, headers, body]
    end

  protected
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
      query_string = ''
      if request['QUERY_STRING'] != '' and request['QUERY_STRING'] != nil
        query_string = '?' + request['QUERY_STRING']
      end

      "#{request['PATH_INFO']}#{query_string}"
    end

    def absolute_url(request)
      "#{request['rack.url_scheme']}://#{host(request)}#{url(request)}"
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

    def stream_size(stream)
      size = nil
      io = StringIO.new
      begin
        stream.write io
        io.flush
        size = io.size
      ensure
        io.close
      end
      size
    end

    def request_content_size(request)
      if request['HTTP_CONTENT_LENGTH']
        request['HTTP_CONTENT_LENGTH'].to_i
      else
        if request['rack.input'].respond_to? :size
          request['rack.input'].size
        elsif request['rack.input'].respond_to? :write
          stream_size(request['rack.input'])
        else
          -1 # Not available
        end
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
      # puts 'BODY: ' << response[:body]
      if response[:headers]['Content-Length']
        response[:headers]['Content-Length'].to_i
      else
        if response[:body].respond_to? :inject
          response[:body].inject(0) { |sum, b| sum + b.bytesize }
        elsif response[:body].respond_to? :write
          stream_size(response[:body])
        else
          -1 # Not available
        end
      end
    end

    def record_alf(startedDateTime, request, response)
      time = Time.now - startedDateTime
      alf = MashapeAnalytics::Message::Alf.new @service_token, @environment

      req_headers_size = request_header_size(request)
      req_content_size = request_content_size(request)

      res_headers_size = response_headers_size(response)
      res_content_size = response_content_size(response)

      entry = {
        startedDateTime: startedDateTime.iso8601,
        serverIpAddress: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address,
        time: (time * 1000).to_i,
        request: {
          method: request['REQUEST_METHOD'],
          url: absolute_url(request),
          httpVersion: 'HTTP/1.1', # not available, default http/1.1
          cookies: [],
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
          cookies: [],
          headers: response_headers(response),
          headersSize: res_headers_size,
          content: {
            size: res_content_size,
            mimeType: response[:headers]['Content-Type'] || 'application/octet-stream'
          },
          bodySize: res_headers_size + res_content_size,
          redirectURL: response[:headers]['Location'] || ''
        },
        cache: {},
        timings: {
          blocked: -1,
          dns: -1,
          connect: -1,
          send: 0,
          wait: (time * 1000).to_i,
          receive: 0,
          ssl: -1
        }
      }

      if @send_body
        require 'base64'
        entry[:request][:content][:encoding] = 'base64'
        request['rack.input'].rewind
        entry[:request][:content][:text] = Base64.strict_encode64(request['rack.input'].read)


        # TODO Handle streams as well
        if response[:body].respond_to? :join
          entry[:response][:content][:encoding] = 'base64'
          entry[:response][:content][:text] = Base64.strict_encode64(response[:body].join())
        end
      end

      alf.add_entry entry
      MashapeAnalytics::Capture.record! alf
    end

  end
end
