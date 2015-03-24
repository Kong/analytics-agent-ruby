puts 'hooks'

require 'apianalytics/frameworks/rack'

# == Sinatra Hook ============================================================
if (defined?(Sinatra))
  print 'loaded sinatra'
  require 'apianalytics/frameworks/sinatra'
end

# == Rails Hook ============================================================

if (defined?(Rails))
  print 'loaded rails'
  require 'apianalytics/frameworks/rails'
end

module ApiAnalytics::Frameworks
end
