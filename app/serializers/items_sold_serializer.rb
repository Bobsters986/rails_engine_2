class ItemsSoldSerializer
  include JSONAPI::Serializer

  attributes :name

  attribute :count do |merchant|
    merchant.item_count
  end
end
