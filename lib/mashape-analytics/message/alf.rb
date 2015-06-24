require 'json'

module MashapeAnalytics::Message
  class Alf
    attr_accessor :test

    def initialize(serviceToken, environment, clientIp = nil)
      @entries = []
      @alf = {
        version: '1.0.0',
        serviceToken: serviceToken,
        environment: environment,
        har: {
          log: {
            version: '1.2',
            creator: {
              name: 'mashape-analytics-agent-ruby',
              version: '1.0.0'
            },
            entries: @entries
          }
        }
      }

      if clientIp
        @alf.clientIpAddress = clientIp
      end
    end

    def add_entry(entry)
      @entries << entry
    end

    def to_s
      @alf.to_json
    end
  end
end
