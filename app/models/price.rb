class Price

  include Virtus.model
  include ActiveModel::Model
  include ActiveModel::SerializerSupport

  attribute :amount, BigDecimal 
  attribute :currency, String
  
end
