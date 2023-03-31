require 'rails_helper'

RSpec.describe "Items Search API", type: :request do
  context "find#index" do
    let!(:merchant_1) { create(:merchant, name: "Best Buy") }
    let!(:item_1) { create(:item, name: "The One Ring", unit_price: 300.00, merchant: merchant_1) }
    let!(:item_2) { create(:item, name: "Ring Pop", unit_price: 100.00, merchant: merchant_1) }
    let!(:item_3) { create(:item, name: "The Ringer", unit_price: 150.00, merchant: merchant_1) }
    let!(:item_4) { create(:item, name: "X Box", unit_price: 400.00, merchant: merchant_1) }
    let!(:item_5) { create(:item, name: "PS-5", unit_price: 500.00, merchant: merchant_1) }

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
          expect(parsed[:errors]).to eq("No Item names match your search")
        end

        it "returns an error message for missing parameter" do
          get "/api/v1/items/find_all"

          expect(response).to have_http_status(204)
        end

        # xit "returns an error message for empty parameter" do
        #   get "/api/v1/items/find_all?name="
        #   # require 'pry'; binding.pry

        #   expect(response).to have_http_status(204)
        # end
      end
    end

    context "Find All Items By Price Search" do
      context "when successful" do
        it "can find all items by min_price" do
          get "/api/v1/items/find_all?min_price=151"

          expect(response).to be_successful

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(parsed[:data].size).to eq(3)
          expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
          expect(parsed[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
          expect(parsed[:data][0][:attributes][:name]).to eq(item_1.name)
          expect(parsed[:data][1][:attributes][:name]).to eq(item_4.name)
          expect(parsed[:data][2][:attributes][:name]).to eq(item_5.name)
        end

        it "can find all items by max_price" do
          get "/api/v1/items/find_all?max_price=299.99"

          expect(response).to be_successful

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(parsed[:data].size).to eq(2)
          expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
          expect(parsed[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
          expect(parsed[:data][0][:attributes][:name]).to eq(item_2.name)
          expect(parsed[:data][1][:attributes][:name]).to eq(item_3.name)
        end

        it "can find all items by min_price and max_price" do
          get "/api/v1/items/find_all?min_price=150&max_price=500"

          expect(response).to be_successful

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(parsed[:data].size).to eq(4)
          expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
          expect(parsed[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
          expect(parsed[:data][0][:attributes][:name]).to eq(item_3.name)
          expect(parsed[:data][1][:attributes][:name]).to eq(item_1.name)
          expect(parsed[:data][2][:attributes][:name]).to eq(item_4.name)
          expect(parsed[:data][3][:attributes][:name]).to eq(item_5.name)
        end
      end

      context "when UNsuccessful" do
        it "returns error for putting negative number in min_price" do
          get "/api/v1/items/find_all?min_price=-5"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:errors]).to eq("Please enter valid parameters")
        end

        it "returns error for putting negative number in min_price" do
          get "/api/v1/items/find_all?max_price=-5"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:errors]).to eq("Please enter valid parameters")
        end

        it "returns error for attempting to pass a name and min_price param" do
          get "/api/v1/items/find_all?name=ring&min_price=300"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:errors]).to eq("Please enter valid parameters")
        end

        it "returns error for attempting to pass a name and max_price param" do
          get "/api/v1/items/find_all?name=ring&max_price=300"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:errors]).to eq("Please enter valid parameters")
        end

        it "returns error for attempting to pass a name and min_price and max_price param" do
          get "/api/v1/items/find_all?name=ring&min_price=150&max_price=300"

          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:errors]).to eq("Please enter valid parameters")
        end
      end
    end
  end
end