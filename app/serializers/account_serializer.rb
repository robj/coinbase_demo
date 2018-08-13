class AccountSerializer < ActiveModel::Serializer

  attribute :id
  attribute :name
  attribute :primary
  attribute :type
  attribute :currency
  attribute :created_at
  attribute :updated_at
  attribute :resource
  attribute :resource_path

  has_one :balance
  has_one :native_balance
  
end