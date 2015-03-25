puts 'hooks'

# == Rack Hook =============================================================
if (defined?(Rack))
  puts 'rack!'
  require 'apianalytics/frameworks/rack'
end

# == Sinatra Hook ==========================================================
if (defined?(Sinatra))
  puts 'sinatra!'
  require 'apianalytics/frameworks/sinatra'
end

# == Rails Hook ============================================================

if (defined?(Rails))
  puts 'rails!'
  require 'apianalytics/frameworks/rails'
end


module ApiAnalytics::Frameworks
end
