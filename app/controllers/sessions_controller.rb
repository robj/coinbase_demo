class SessionsController < ApplicationController

  def new
  end

  def create
      #for stateless demo purposes, redirect to account#show with API credentials as params
      if (session_params[:return_json] == "1") #check_box checked == 1
        redirect_to api_account_path(api_key: session_params[:api_key], api_secret: session_params[:api_secret])
      else
        redirect_to account_path(api_key: session_params[:api_key], api_secret: session_params[:api_secret])
      end
  end


  private
    # Using a private method to encapsulate the permissible parameters
    # is just a good pattern since you'll be able to reuse the same
    # permit list between create and update. Also, you can specialize
    # this method with per-user checking of permissible attributes.
    def session_params
      params.require(:user).permit(:api_key, :api_secret, :return_json)
    end

end