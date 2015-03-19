module ApiAnalytics::Message
  class Entry
    attr_accessor :serverIpAddress, :clientIpAddress, :time

    def initialize(startedDateTime, request, response, timings)
    end

  end
end
