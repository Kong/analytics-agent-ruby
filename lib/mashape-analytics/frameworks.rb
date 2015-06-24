
# == Rack Hook =============================================================
if (defined?(Rack))
  require 'mashape-analytics/frameworks/rack'
end

# == Sinatra Hook ==========================================================
if (defined?(Sinatra))
  require 'mashape-analytics/frameworks/sinatra'
end

# == Rails Hook ============================================================

if (defined?(Rails))
  require 'mashape-analytics/frameworks/rails'
end


module MashapeAnalytics::Frameworks
end
