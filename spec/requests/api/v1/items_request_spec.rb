require 'rails_helper'

RSpec.describe "Items API", type: :request do
  before do
    create_list(:item, 3)
  end

  context "#index" do
    before do
      get '/api/v1/items'
    end

    context "when successful" do
      it "returns all items" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data]).to be_an(Array)
        expect(parsed[:data].size).to eq(3)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:attributes].size).to eq(4)
        expect(parsed[:data][0][:attributes][:name]).to eq(Item.first.name)
        expect(parsed[:data][0][:attributes][:description]).to eq(Item.first.description)
        expect(parsed[:data][0][:attributes][:unit_price]).to eq(Item.first.unit_price)
        expect(parsed[:data][0][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][0][:attributes][:merchant_id]).to eq(Item.first.merchant_id)
      end
    end
  end
end