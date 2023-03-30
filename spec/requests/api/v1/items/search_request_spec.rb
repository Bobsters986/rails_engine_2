require 'rails_helper'

RSpec.describe "Items Search API", type: :request do
  context "find#index" do
    let!(:merchant_1) { create(:merchant, name: "Best Buy") }
    let!(:item_1) { create(:item, name: "The One Ring", unit_price: 5, merchant: merchant_1) }
    let!(:item_2) { create(:item, name: "Ring Pop", unit_price: 10, merchant: merchant_1) }
    let!(:item_3) { create(:item, name: "The Ringer", unit_price: 10, merchant: merchant_1) }
    let!(:item_4) { create(:item, name: "X Box", unit_price: 15, merchant: merchant_1) }
    let!(:item_5) { create(:item, name: "PS-5", unit_price: 30, merchant: merchant_1) }

    context "Find All Items By Name Search" do
      context "when successful" do
        it "can find all items by the search parameters" do
          get "/api/v1/items/find_all?name=ring"

          expect(response).to be_successful

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(parsed[:data]).to be_an(Array)
          expect(parsed[:data].size).to eq(3)
          expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
          expect(parsed[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
          expect(parsed[:data][0][:attributes][:name]).to eq(item_2.name)
          expect(parsed[:data][1][:attributes][:name]).to eq(item_1.name)
          expect(parsed[:data][2][:attributes][:name]).to eq(item_3.name)
        end
      end

      context "when UNsuccessful" do
        it "returns an error message for no matching names" do
          get "/api/v1/items/find_all?name=wrong"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(200)
          expect(parsed[:message]).to eq("your query could not be completed")
          expect(parsed[:errors]).to eq("No Item names match your search")
        end

        it "returns an error message for missing parameter" do
          get "/api/v1/items/find_all"

          expect(response).to have_http_status(204)
        end

        xit "returns an error message for empty parameter" do
          get "/api/v1/items/find_all?name="
          # require 'pry'; binding.pry

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end