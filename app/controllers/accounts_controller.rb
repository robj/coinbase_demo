require 'coinbase/wallet'

class AccountsController < ApplicationController

  def show

     unless (params.has_key?('api_key') && params.has_key?('api_secret'))
        render plain: 'missing api credentials', status: :unprocessable_entity and return 
     end 

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