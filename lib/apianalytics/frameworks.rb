require 'apianalytics/frameworks/sinatra'

# == Rails Hook ============================================================

if (defined?(Rails))
  print 'loaded rails'
  require 'apianalytics/frameworks/rails'
end

module ApiAnalytics::Frameworks
end
