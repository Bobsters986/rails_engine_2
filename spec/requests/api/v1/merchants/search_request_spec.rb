require 'rails_helper'

RSpec.describe "Merchants Search API", type: :request do
  context "find#show" do
    let!(:merchant_1) { create(:merchant, name: "Turing") }
    let!(:merchant_2) { create(:merchant, name: "Ring World") }
    let!(:merchant_3) { create(:merchant, name: "One Ring to Rule them All") }

    context "when successful" do
      it "can find a merchant by the search parameters" do
        get "/api/v1/merchants/find?name=ring"

        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].keys).to eq([:name])
        expect(parsed[:data][:id]).to eq(merchant_3.id.to_s)
        expect(parsed[:data][:type]).to eq('merchant')
        expect(parsed[:data][:attributes][:name]).to eq(merchant_3.name)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for no matching names" do
        get "/api/v1/merchants/find?name=wrong"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(200)
        expect(parsed[:message]).to eq("your query could not be completed")
        expect(parsed[:errors]).to eq("No Merchant names match your search")
      end
    end
  end
end