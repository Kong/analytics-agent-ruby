require 'sinatra/base'
require 'apianalytics/capture'
require 'time'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(api_key, host='socket.apianalytics.com:5000')
      ApiAnalytics::Capture.connect('tcp://' + host)

      before do
        @startedDateTime = Time.now.iso8601
        # request.startedDateTime = Time.now.iso8601
        # print 'before'
        # puts request
      end

      after do
        puts @startedDateTime
        # puts response
        entry = ApiAnalytics::Message::Alf.new
        ApiAnalytics::Capture.record! entry
      end
    end

  end
end
