require 'apianalytics/utils'

module ApiAnalytics
  class Capture
    require 'rbczmq'

    @@zmq_ctx = ZMQ::Context.new
    @zmq_push = nil
    @connected = false
    @options = {
      host: 'tcp://socket.apianalytics.com:5000'
    }
    @thread = nil

    @@queue = Utils::QueueWithTimeout.new

    def self.start
      return unless @thread == nil

      @thread = Thread.new do
        # Connect
        @zmq_push = @@zmq_ctx.socket(:PUSH)
        @zmq_push.connect(@options[:host])
        @connected = true

        # Send messages
        while @connected
          begin
            alf = @@queue.pop_with_timeout(1)  # 1s timeout
            @zmq_push.send alf.to_s
          rescue => ex
            # TODO log debug
            # puts 'timeout'
          end
        end

        # Disconnect
        @zmq_push.close

        # Clean up
        @zmq_push = nil
        @connected = false
        @thread = nil
      end
    end

    ##
    # Send immediately
    ##
    def self.record!(alf)
      if not @connected
        Capture.start
      end

      @@queue << alf
    end

    ##
    # Force disconnect
    ##
    def self.disconnect
      return unless @connected

      @connected = false
      @thread.join
    end

    def self.context
      @@zmq_ctx
    end

    def self.setOptions(options)
      @options.merge! options
    end

  end
end
