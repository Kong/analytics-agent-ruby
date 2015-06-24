# Mashape Analytics Ruby Agent

> for more information on Mashape Analytics, please visit [apianalytics.com](https://www.apianalytics.com)

## Requirements

- [ZeroMQ](http://zeromq.org/intro:get-the-software)


## Installation


```sh
gem 'mashape-analytics'
bundle install
```

## Usage

### Ruby on Rails

Open your `config/environment.rb` file, and within the `Rails::Initializer.run` block, add the middleware as below:

```ruby
require 'mashape-analytics'

Rails::Initializer.run do |config|
  config.middleware.use MashapeAnalytics::Frameworks::Rails, service_token: 'SERVICE_TOKEN', environment: 'production'
end
```

*In rails 4, put the `config.middleware.use` line in the `config/application.rb` file.*


### Sinatra

Register the middleware. Then activate it.

```ruby
# myapp.rb
require 'sinatra'
require 'mashape-analytics'

register MashapeAnalytics::Frameworks::Sinatra

mashapeAnalytics! 'SERVICE_TOKEN', environment: 'production'
```


### Rack

Add the middleware.

```ruby
require 'rack'
require 'mashape-analytics'

use MashapeAnalytics::Frameworks::Rack, service_token: 'SERVICE_TOKEN', environment: 'production'
```


## Copyright and License

Copyright Mashape Inc, 2015.

Licensed under [the MIT License](https://github.com/mashape/analytics-agent-ruby/blob/master/LICENSE)
