class AccountSerializer < ActiveModel::Serializer

  attribute :id
  attribute :name
  attribute :primary
  attribute :type
  attribute :currency
  attribute :balance
  attribute :created_at
  attribute :updated_at
  attribute :resource
  attribute :resource_path
  attribute :native_balance
  
end