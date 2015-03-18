module ApiAnalytics
  module Rails

    def apianalytics!(api_key)
      before_filter do
        print 'before'
        puts request
      end

      before_filter do
        print 'after'
        puts response
      end
    end

  end
end
