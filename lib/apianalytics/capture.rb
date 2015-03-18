module ApiAnalytics
	class Capture
    @zmq_ctx = nil
    @zmq_socket = nil

    def self.bind_socket(host='tcp://socket.apianalytics.com:5000')
      @zmq_ctx = ZMQ::Context.create(1)
      @zmq_socket = @zmq_ctx.socket(ZMQ::PUSH)
      @zmq_socket.bind(host)
    end

    def self.record!(entry)
      if @zmq_socket == nil
        bind_socket!
      end

      @zmq_socket.send_string 'test'
    end

    def self.destroy_socket
      @zmq_socket.close
      @zmq_ctx.terminate

      @zmq_socket = nil
      @zmq_ctx = nil
    end

    def self.socket
      @zmq_socket || nil
    end

  end
end
