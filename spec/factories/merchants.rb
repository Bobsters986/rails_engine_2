FactoryBot.define do
  factory :merchant do
    name {Faker::Name.name}
    # association :invoices, :items
  end
end