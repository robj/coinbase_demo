class SessionsController < ApplicationController

  def new
  end

  def create
      render plain: "sessions#create\napi_key: #{session_params[:api_key]}"
  end


  private
    # Using a private method to encapsulate the permissible parameters
    # is just a good pattern since you'll be able to reuse the same
    # permit list between create and update. Also, you can specialize
    # this method with per-user checking of permissible attributes.
    def session_params
      params.require(:user).permit(:api_key, :api_secret)
    end

end