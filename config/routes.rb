Rails.application.routes.draw do

    root :to => "sessions#new"

    resource :account
    resource :sessions

    namespace :api, defaults: {format: :json} do
      scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
        resource :account
      end
    end

end
