# Coinbase Account Viewer


A simple application to demonstrate the following:

- Ruby on Rails Development best practices
- Modern Javascript (ES6 classes, promises) / unobstructive JS
- Coinbase API
- RESTful design
- 12 Factor configuration
- Containerized/Dockerized deployment


The app requests the primary wallet (the API key used must have the "wallet:accounts:read" auth scope) and displays wallet information to the user as a HTML page or alternatively (via checkbox) uses the API controller to return the account in JSON format.

Examples of server side apps that make similar requests with a coinbase user's API credentials include portfolio trackers, and tax calculation apps. Concepts demonstrated here can be used as a starting point to build a more fully functioned app.

## Design

### Simplified Demo

- No persistence: Virtus models are used rather than ActiveRecord models (no Database)
- Stateless: No real session managment implemented.
 

### Security

- SSL required to protect API credentials from middleman attacks.
- Due to the demo's stateless nature, the accounts#show action exposes the api_secret param in the URL (which looks particulary insecure to an end user) and would not be recommended for this behaviour to exist in a production app. (eg. risk of saving API secret into a browser bookmark)

### Models

- User: API credentials
- Account: Replicate coinbase account object 
- Price: Amount/Currency pair. (use BigDecimal when working with prices)

### Controllers

- Session: Simple login flow from sessions#new to account#show. 
- Account: Show account details (singular route)

### Business Logic

- CoinbaseAccountParser

`/app/lib/coinbase_account_parser.rb`

### Gems

- Virtus: 'Attributes on Steroids for Plain Old Ruby Objects'. Simple PORO models and object initialisation / associations / ruby type coersion from a JSON hash.

- Coinbase: 'official client library for the Coinbase Wallet API v2'

- SettingsLogic: Encapsulate app/env configuration

- Dotenv: source .env in development environment

### Settings


- Settingslogic - pull in ENV vars for app config (12 factor)

`config/application.yml`

```
defaults: &defaults
  web_frontend:
    price_ticker:
      enabled: <%= ENV['WEB_FRONTEND_PRICE_TICKER_ENABLED'] %>
      refresh: <%= ENV['WEB_FRONTEND_PRICE_TICKER_REFRESH'] %>

  coinbase:
    api:
      base_url: <%= ENV['COINBASE_API_BASE_URL'] %>

```

- In development use Dotenv to source `.env` , in production these are configured in the app platform.

```
export WEB_FRONTEND_PRICE_TICKER_ENABLED=true
export WEB_FRONTEND_PRICE_TICKER_REFRESH=5
export COINBASE_API_BASE_URL="https://api.coinbase.com/v2/"
```

### Versioned RESTful JSON API

- v1 by default unless version header specifies otherwise. Boilerplate from http://jes.al/2013/10/architecting-restful-rails-4-api/
- API uses ActiveModelSerializers for serialization

see

`/app/lib/api_constraints.rb`

`/app/controllers/api/v1/accounts_controller.rb`

`/app/serializers/account_serializer.rb`

`/app/serializers/price_serializer.rb`

Note: Price.amount (BigDecimal) is serialized as a string as per default behavior, see discussion:

```
https://stackoverflow.com/questions/6128794/rails-json-serialization-of-decimal-adds-quotes

https://github.com/rails/rails/issues/6033

https://github.com/rails/rails/pull/6040
```

### Tests

A single spec exists for CoinbaseAccountParser.

`spec/lib/coinbase_account_parser_spec.rb`

This is live (not mocked) therefore requires `COINBASE_API_KEY` and `COINBASE_API_SECRET` env vars to run.

`$ COINBASE_API_KEY=2qOhIaJoEW8G02Y4 COINBASE_API_SECRET=<your_api_secret> bundle exec rspec  -f d`

```
CoinbaseAccountParser
  #.get_account
    returns true and Account object upon successful request to Coinbase API
    returns false and error message upon unsuccessful request to Coinbase API

Finished in 0.76453 seconds (files took 2.8 seconds to load)
2 examples, 0 failures
```

### Javascript Ticker

`app/assets/javascripts/price_ticker.js`

If enabled in Settings/ENV then initialised from:

`app/assets/javascripts/application.js.erb`


## Dockerized Deployment

### Dockerfile

- logs to stdout as per 12 factor

```
FROM ruby:2.5.1-stretch

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y --force-yes \
  build-essential \
  nodejs \
  yarn


ENV RAILS_ENV production
ENV RACK_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5


# Copy the main application.
COPY . ./

# Precompile Assets
RUN bundle exec rake assets:precompile


# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000
```

###AWS


#### Elastic Beanstalk

* New Application through wizard *coinbase_demo*
  * New environment *coinbase-demo-prd*  
     * Platform: Docker

#### Elastic Container Registry

* New Docker Repository *coinbase_demo*

#### IAM

##### Users

- New User *cb_deploy* with programatic API access (access key/secret)

Permissions:

* AWSElasticBeanstalkFullAccess
* AmazonEC2ContainerRegistryPowerUser


##### Roles
  
  Added `AmazonEC2ContainerRegistryReadOnly` policy to `aws-elasticbeanstalk-ec2-role`



#### Docker build and push to AWS ECR repository

Environment `aws_deploy_env.sh` (not stored in repo, gitignored)

```
export AWS_ACCESS_KEY_ID=AKIAJBDD6O4UDZ3N6OZA
export AWS_SECRET_ACCESS_KEY=<key>
export AWS_REGION=us-east-1
export ECR_REPOSITORY=902981585923.dkr.ecr.us-east-1.amazonaws.com
export APP_NAME=coinbase_demo
export DOCKER_TAG=$APP_NAME:latest
```

Build and Push script 

`build_docker_and_push_to_ecr.sh`

```
#!/bin/bash

DEPLOY_ENV_FILENAME="aws_deploy_env.sh"

if [ ! -f $DEPLOY_ENV_FILENAME ]; then
    echo "$DEPLOY_ENV_FILENAME required"
    exit 1
else
    source $DEPLOY_ENV_FILENAME
fi

if [ ! $(which aws) ]; then
    echo "AWS CLI utilities not installed"
    exit 1
fi

if [ ! $(which docker) ]; then
    echo "Docker not installed"
    exit 1
fi

#login
$(aws ecr get-login --no-include-email --region $AWS_REGION)

#build
docker build -t $APP_NAME .

#tag
docker tag $DOCKER_TAG $ECR_REPOSITORY/$DOCKER_TAG

#push
docker push $ECR_REPOSITORY/$DOCKER_TAG
```

#### Elastic Beanstalk App config

[Install awsebcli tools](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)

init with default options

```
$ eb init
```

configure EB to deploy via Dockerrun.aws.json artifact

`Dockerrun.aws.json`

```
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "902981585923.dkr.ecr.us-east-1.amazonaws.com/coinbase_demo:latest",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": "3000"
    }
  ]
}
```

`.elasticbeanstalk/config.yml`

```
branch-defaults:
  master:
    environment: coinbase-demo-prd
global:
  application_name: coinbase_demo
  default_ec2_keyname: null
  default_platform: 64bit Amazon Linux 2018.03 v2.12.0 running Docker 18.03.1-ce
  default_region: us-east-1
  profile: eb-cli

deploy:
  artifact: Dockerrun.aws.json
```
 
  
#### Elastic Beanstalk Environment

```
$ eb status
  Application name: coinbase_demo
  Region: us-east-1
  Deployed Version: app-0d15-180814_175529
  Environment ID: e-fnfpbyypap
  Platform: 64bit Amazon Linux 2018.03 v2.12.0 running Docker 18.03.1-ce
  Tier: WebServer-Standard-1.0
  CNAME: coinbase-demo-prd.us-east-1.elasticbeanstalk.com
  Updated: 2018-08-14 16:57:01.117000+00:00
  Status: Ready
  Health: Green
```

```
$ eb printenv
 Environment Variables:
     COINBASE_API_BASE_URL = https://api.coinbase.com/v2/
     WEB_FRONTEND_PRICE_TICKER_ENABLED = true
     WEB_FRONTEND_PRICE_TICKER_REFRESH = 5
```

```
$ eb setenv COINBASE_API_BASE_URL=https://api.coinbase.com/v2/
```



#### Elastic Beanstalk Deploy

- Deploys docker image from ECR as per Dockerrun.aws.json

```
$ eb deploy
```

#### Elastic Beanstalk Instance SSH

```
$ eb ssh
```

## Unresolved deployment concerns

- Hardcoded ECR repository in `Dockerrun.aws.json`



## Git Log

`git shortlog`

```
robj (67):
      new rails 5 application
      home controller and views
      account controller and views
      initial home and singular account route
      add virtus gem
      working sessions user login form
      initial Account model
      replaced home controller with sessiosn controller
      document design decisions
      add coinbase gem
      account model matching coinbase account
      coinbase account parsing and views
      redirect from sessions#create to account#show with api credentials submitted
      updated docs
      remove unused account#index view
      basic versioned API plumbing from http://jes.al/2013/10/architecting-restful-rails-4-api/
      base API v1 controller
      initial api v1 accounts controller
      add active_model_serializers gem, use 0-8 branch for Virtus compatability
      include ActiveModel::SerializerSupport for AMS support
      initial account serializer
      account parse and return json
      error handling: ensure required params are present
      fix indentation
      fix indentation
      return json from api option
      return json from api checkbox
      add bootstrap to application layout using CDN
      boostrap container in application layout
      use bootstrap 4, add navbar
      give main container 40px margin from top
      button styling
      table bs css classes
      updated docs
      update docs
      add rspec
      not using DB, so remove active record references from rspec rails helper
      initial spec for coinbase_account_parser
      add rspec test docs
      update docs
      additionally test to be_a_kind_of(Account)
      update docs
      add settingslogic, config from env vars
      configure price ticker through settingslogic + ENV
      add JS price ticker
      price ticker config
      make JS unobtrusive, move initializePriceTickerPolling to application.js
      fadeIn on price ticker html change
      properly handle Price as a class rather than coercsion into a Hash
      pretty print dates
      updated docs
      production uglifier support for ES6 syntax
      conditional initialisation of price ticker not compatible with precompilation, move initialise code from application.js back into a the top_navbar partial
      moved from application.js.erb back to application.js
      add Dockerfile
      add AWS ElasticBeanstlak config
      Dockerrun.aws.json
      update gitignore with elasticbeanstalk * aws_deploy_env exclusions
      add docker build and push script
      check awscli and docker installed before running
      rename ambiguous API_KEY to COINBASE_API_KEY in spec
      rename ambiguous API_KEY to COINBASE_API_KEY in docs
      load .env with Dotenv in development and test envs
      use dotenv-rails over dotenv
      Dotenv.load if Rails.env.development?
      development .env file sources by Dotenv
      doc update
      proper use of bs4 padding class
      warning about api credentials over non-secure connection
```
