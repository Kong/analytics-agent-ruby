require 'sinatra/base'
require 'apianalytics/capture'
require 'time'

module ApiAnalytics::Frameworks
  module Sinatra

    def apianalytics!(service_token, host='socket.apianalytics.com:5000')
      ApiAnalytics::Capture.connect('tcp://' + host)

      before do
        @startedDateTime = Time.now
      end

      after do
        alf = ApiAnalytics::Message::Alf.new service_token

        entry = {
          startedDateTime: @startedDateTime.iso8601,
          request: {},
          response: {},
          timings: {}
        }

        alf.add_entry entry

        ApiAnalytics::Capture.record! alf
      end
    end

  end
end
