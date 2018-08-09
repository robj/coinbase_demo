class Account
 include Virtus.model
 include ActiveModel::Model

 attribute :id, String
 attribute :name, String
 attribute :primary, Boolean
 attribute :type, String
 attribute :currency, String
 attribute :balance, Hash
 attribute :created_at, DateTime
 attribute :updated_at, DateTime
 attribute :resource, String
 attribute :resource_path, String
 attribute :native_balance, Hash

end



# example account JSON returned from Coinbase API
#
#   "id"   =>"8d8d1fea-30d8-54a1-99b8-f5b451baa2a9",
#   "name"   =>"BTC Wallet",
#   "primary"   =>true,
#   "type"   =>"wallet",
#   "currency"   =>"BTC",
#   "balance"   =>   {  
#      "amount"      =>"0.00000000",
#      "currency"      =>"BTC"
#   },
#   "created_at"   =>"2016-11-17T06:23:14   Z",
#   "updated_at"   =>"2017-12-22T03:29:43   Z",
#   "resource"   =>"account",
#   "resource_path"   =>"/v2/accounts/8d8d1fea-30d8-54a1-99b8-f5b451baa2a9",
#   "native_balance"   =>   {  
#      "amount"      =>"0.00",
#      "currency"      =>"USD"
#   }#