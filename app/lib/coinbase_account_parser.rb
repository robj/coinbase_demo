require 'coinbase/wallet'

class CoinbaseAccountParser

    attr_accessor :account
    attr_accessor :error

    def get_account(api_key,api_secret)

        begin
            client = Coinbase::Wallet::Client.new(api_key: api_key, api_secret: api_secret)
            self.account = Account.new(client.primary_account)
            return true
        rescue Coinbase::Wallet::APIError => e
            self.error = e
            return false
        end

    end

end