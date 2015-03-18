require 'apianalytics/sinatra'

# == Rails Hook ============================================================

if (defined?(Rails))
  print 'loaded rails'
  require 'apianalytics/rails'
end
