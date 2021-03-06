# elastic-apm – Elastic APM agent for Ruby (BETA)

[![Jenkins](https://img.shields.io/jenkins/s/https/apm-ci.elastic.co/job/elastic+apm-agent-ruby+master.svg)](https://apm-ci.elastic.co/job/elastic+apm-agent-ruby+master/) [![Gem](https://img.shields.io/gem/v/formatador.svg?style=flat-square)](https://rubygems.org/gems/elastic-apm)

This is the official Rubygem for adding [Elastic][]'s [APM][] to your Ruby app.

## Setup

Add the gem to your `Gemfile`:

```ruby
gem 'elastic-apm'
```

## Getting started with Rails

If you're using Rails the gem automatically inserts itself where it needs to be.

_Describe configuration using yaml, config, etc_

### Optional: Configure the agent

The suggested way to configure is to create a file `config/elastic_apm.yml` with your config:

```yaml
# config/elastic_apm.yml

server_url: http://localhost:8200
secret_token: YOUR_SECRET
```

## Getting started with Sinatra

```ruby
# config.ru

require 'sinatra/base'

class MySinatraApp < Sinatra::Base
  use ElasticAPM::Middleware
  
  # ...
end

# Takes optional ElasticAPM::Config values
ElasticAPM.start(
  app: MySinatraApp, # required
  server_url: 'http://localhost:8200'
)

run MySinatraApp

at_exit { ElasticAPM.stop }
```

# License

Apache 2.0

[Elastic]: https://elastic.co
[APM]: https://www.elastic.co/guide/en/apm/server/index.html
