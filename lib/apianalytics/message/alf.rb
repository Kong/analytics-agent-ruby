require 'json'

module ApiAnalytics::Message
  class Alf
    attr_accessor :test

    def initialize(serviceToken)
      @entries = []
      @alf = {
        serviceToken: serviceToken,
        har: {
          log: {
            version: '1.2',
            creator: {
              name: 'Ruby Agent',
              version: '1.0.0'
            },
            entries: @entries
          }
        }
      }
    end

    def add_entry(entry)
      @entries << entry
    end

    def to_s
      @alf.to_json
    end
  end
end
