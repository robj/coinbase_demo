class Api::V1::AccountsController < Api::V1::BaseController

  def show

     unless (params.has_key?('api_key') && params.has_key?('api_secret'))
        render json: {error: 'missing api credentials'}, status: :unprocessable_entity and return 
     end 
     
     cap = CoinbaseAccountParser.new

     if cap.get_account(params[:api_key],params[:api_secret])
        render json: cap.account
     else
        render json: {error: cap.error}, status: :bad_request
     end

  end

end
