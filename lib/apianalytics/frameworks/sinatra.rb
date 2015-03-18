require 'apianalytics/capture'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(api_key, host='socket.apianalytics.com:5000')
      before do
        # print 'before'
        # puts request
      end

      after do
        # print 'after'
        # puts response
        entry = ApiAnalytics::Message::Entry.new
        ApiAnalytics::Capture.record! entry
      end
    end

  end
end
