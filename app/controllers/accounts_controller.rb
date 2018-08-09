require 'coinbase/wallet'

class AccountsController < ApplicationController

    def show

         cap = CoinbaseAccountParser.new
         
         if cap.get_account(params[:api_key],params[:api_secret])
            @account = cap.account
            @error = nil
         else
            @account = nil
            @error = cap.error
         end

    end

end