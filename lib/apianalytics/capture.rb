
module ApiAnalytics
  class Capture
    require 'rbczmq'
    @@zmq_ctx = ZMQ::Context.new
    @zmq_push = nil

    def self.connect(host='tcp://socket.apianalytics.com:5000')
      return if @zmq_push != nil
      @zmq_push = @@zmq_ctx.socket(:PUSH)
      rc = @zmq_push.connect(host)
    end

    ##
    # send as necessary
    ##
    def self.record(alf)
      if @zmq_push == nil
        connect
      end

      # TODO buffer entries
    end

    ##
    # send immediately
    ##
    def self.record!(alf)
      if @zmq_push == nil
        connect
      end

      @zmq_push.send alf.to_s
    end

    def self.disconnect
      if @zmq_push != nil
        @zmq_push.close
        @zmq_push = nil
      end
    end

    def self.socket
      @zmq_push || nil
    end

    def self.context
      @@zmq_ctx
    end

  end
end
