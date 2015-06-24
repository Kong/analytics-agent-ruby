# Mashape Analytics Ruby Agent

> for more information on Mashape Analytics, please visit [apianalytics.com](https://www.apianalytics.com)

## Installation

Add the gem to your Gemfile and install the gem:

```sh
gem 'apianalytics'
bundle install
```

## Usage

### Ruby on Rails

Open your `config/environment.rb` file, and within the `Rails::Initializer.run` block, add the middleware as below:

```ruby
require 'apianalytics'

Rails::Initializer.run do |config|
  config.middleware.use ApiAnalytics::Frameworks::Rails, service_token: 'SERVICE_TOKEN'
end
```

*In rails 4, put the `config.middleware.use` line in the `config/application.rb` file.*

### Sinatra

Register the middleware. Then activate it.

```ruby
# myapp.rb
require 'sinatra'
require 'apianalytics'

register ApiAnalytics::Frameworks::Sinatra

apianalytics! 'SERVICE_TOKEN'
```


### Rack

Add the middleware.

```ruby
require 'rack'
require 'apianalytics'

use ApiAnalytics::Frameworks::Rack, service_token: 'SERVICE_TOKEN'
```

## Copyright and license

Copyright Mashape Inc, 2015.

Licensed under [the MIT License](https://github.com/mashape/analytics-agent-java/blob/master/LICENSE)
