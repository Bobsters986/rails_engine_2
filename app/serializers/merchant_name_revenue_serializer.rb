class MerchantNameRevenueSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :revenue do |merchant|
    merchant.revenue
  end
end