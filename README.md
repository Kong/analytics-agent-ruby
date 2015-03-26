# API Analytics Ruby Agent

The ruby agent reports API traffic to [API Analytics](http://apianalytics.com).


## Quick Start

1. Add the gem to your Gemfile and install the gem

    ```text
    gem 'apianalytics'
    bundle install
    ```

2. Follow the guide that tailors to your framework.

### Ruby on Rails

Open your `environment.rb` file, and within the `Rails::Initializer.run` block, add the middleware as below:

```ruby
Rails::Initializer.run do |config|
  config.middleware.use "ApiAnalytics::Frameworks::Rails", service_token: 'SERVICE_TOKEN'
end
```

In rails 4, put the `config.middleware.use` line in the `application.rb` file.

### Sinatra

Register the middleware. Then activate it.

```ruby
# myapp.rb
require 'sinatra'
require 'apianalytics'

register ApiAnalytics::Frameworks::Sinatra

apianalytics! 'SERVICE_TOKEN'

# ... the rest of your code ...
```


### Rack

Add the middleware.

```ruby
require 'rack'
require 'apianalytics'

use ApiAnalytics::Frameworks::Rack, service_token: 'SERVICE_TOKEN'

# ... the rest of your code ...
```


## Contributing to apianalytics

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


