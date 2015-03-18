module ApiAnalytics
	class Capture
    @zmq_ctx = nil
    @zmq_push = nil

    def self.error_check(rc)
      if ZMQ::Util.resultcode_ok?(rc)
        return true
      else
        STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
        caller(1).each { |callstack| STDERR.puts(callstack) }
        return false
      end
    end

    def self.connect(host='tcp://socket.apianalytics.com:5000')
      @zmq_ctx = ZMQ::Context.create(1)
      @zmq_push = @zmq_ctx.socket(ZMQ::PUSH)
      @zmq_push.setsockopt(ZMQ::LINGER, 0)
      rc = @zmq_push.connect(host)

      error_check(rc)
    end

    ##
    # send as necessary
    ##
    def self.record(entry)
      if @zmq_push == nil
        connect
      end

      # TODO buffer entries
    end

    ##
    # send immediately
    ##
    def self.record!(entry)
      if @zmq_push == nil
        connect
      end

      rc = @zmq_push.send_string entry.to_string
      error_check(rc)
    end

    def self.disconnect
      if @zmq_push != nil
        @zmq_push.close
        @zmq_push = nil
      end

      if @zmq_ctx != nil
        @zmq_ctx.terminate
        @zmq_ctx = nil
      end
    end

    def self.socket
      @zmq_push || nil
    end

  end
end
