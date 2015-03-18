# API Analytics Ruby Agent

The ruby agent reports API traffic to [API Analytics](http://apianalytics.com).


## Quick Start

1. Add the gem to your Gemfile.

    ```text
    gem 'apianalytics'
    ```

2. Install the gem.

    ```shell
    bundle install
    ```

3. Follow the guide that tailors to your framework.

### Ruby on Rails

Within your `ApplicationController` add a before and after filter.

```ruby
class ApplicationController < ActionController:Base
  after_filter apianalytics_after, 'MY-API-KEY'

  # ... the rest of your code ...
end
```

### Sinatra

```ruby
# myapp.rb
require 'sinatra'
require 'apianalytics'

before ApiAnalytics.before
after ApiAnalytics.after

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


