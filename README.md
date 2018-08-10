# Coinbase Account Viewer


A simple application to demonstrate the following:

- Rails Development
- Coinbase API
- RESTful design
- 12 Factor
- Containerized/Dockerized deployment


The app requests the primary wallet (the API key used must have the "wallet:accounts:read" auth scope) and displays wallet information to the user as a HTML page or alternatively (via checkbox) uses the API controller to return the account in JSON format.

Examples of server side apps that make similar requests with a coinbase user's API credentials include portfolio trackers, and tax calculation apps. Concepts demonstrated here can be used as a starting point to build a more fully function app.

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

### Controllers

- Session: Simple login flow from sessions#new to account#show. 
- Account: Show account details (singular route)

### Business Logic

- CoinbaseAccountParser

`/app/lib/coinbase_account_parser.rb`

### Gems

- Virtus: 'Attributes on Steroids for Plain Old Ruby Objects'. Simple PORO models and object initialisation / ruby type coersion from a JSON hash.

- Coinbase: 'official client library for the Coinbase Wallet API v2'

### Versioned RESTful JSON API

- v1 by default unless version header specifies otherwise. Boilerplate from http://jes.al/2013/10/architecting-restful-rails-4-api/
- API uses ActiveModelSerializers for serialization

see

`/app/lib/api_constraints.rb`

`/app/controllers/api/v1/accounts_controller.rb`

`/app/serializers/account_serializer.rb`


### Tests

A single spec exists for CoinbaseAccountParser.

`spec/lib/coinbase_account_parser_spec.rb`

This is live (not mocked) therefore requires `API_KEY` and `API_SECRET` env vars to run.

`$ API_KEY=2qOhIaJoEW8G02Y4 API_SECRET=<your_api_secret> bundle exec rspec`

```
CoinbaseAccountParser
  #.get_account
    returns true and Account object upon successful request to Coinbase API
    returns false and error message upon unsuccessful request to Coinbase API

Finished in 0.76453 seconds (files took 2.8 seconds to load)
2 examples, 0 failures
```


## Dockerized Deployment