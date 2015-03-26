puts 'hooks'

# == Rack Hook =============================================================
if (defined?(Rack))
  require 'apianalytics/frameworks/rack'
end

# == Sinatra Hook ==========================================================
if (defined?(Sinatra))
  require 'apianalytics/frameworks/sinatra'
end

# == Rails Hook ============================================================

if (defined?(Rails))
  require 'apianalytics/frameworks/rails'
end


module ApiAnalytics::Frameworks
end
