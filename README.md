## Coinbase Account Viewer


A simple application to demonstrate the following:

- Rails Development
- Coinbase API
- RESTful design
- 12 Factor
- Containerized/Dockerized deployment

Examples of server side apps that make requests with a coinbase user's API credentials include portfolio trackers, and tax calculation apps. 

## Design

### Simplified Demo

- No persistence: Virtus models are used rather than ActiveRecord models (no Database)
- Stateless: No real session managment implemented.
 

### Security

- SSL required to protect API credentials from middleman attacks.
- Due to the demo's stateless nature, the accounts#show action exposes the api_secret param in the URL (which looks particulary insecure to an end user).

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

- Virtus: 'Attributes on Steroids for Plain Old Ruby Objects'. Simple PORO models and object initialisation / type coersion from a JSON hash.

- Coinbase: 'official client library for the Coinbase Wallet API v2'

### Versioned RESTful JSON API

- v1 by default unless version header specifies. Boilerplate from http://jes.al/2013/10/architecting-restful-rails-4-api/
- API uses ActiveModelSerializers for serialization

see

`/app/lib/api_constraints.rb`

`/app/controllers/api/v1/accounts_controller.rb`

`/app/serializers/account_serializer.rb`





