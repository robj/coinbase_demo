## Coinbase Account Viewer


A simple application to demonstrate the following:

- Ruby Development
- Coinbase API
- RESTful design
- TDD
- 12 Factor
- Containerized/Dockerized deployment

Examples of a server side apps that make requests with a coinbase user's API credentials include portfolio trackers, and tax calculation apps. 

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

### Gems

- Virtus: 'Attributes on Steroids for Plain Old Ruby Objects'. Simple PORO models and object initialisation / type coersion from a JSON hash.

- Coinbase: 'official client library for the Coinbase Wallet API v2'