require 'apianalytics'

class RailsTestController < ActionController::Base

  after_filter apianalytics_after, 'abc'

end
