require 'apianalytics/capture'


module ApiAnalytics
  module Sinatra

    def apianalytics!(api_key, host='socket.apianalytics.com:5000')
      print api_key
      before do
        print 'before'
        puts request
      end

      after do
        ApiAnalytics::Capture.record!
        print 'after'
        puts response
      end
    end

  end
end
