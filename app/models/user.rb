class User
 include Virtus.model
 include ActiveModel::Model

 attribute :api_key, String
 attribute :api_secret, String

end

