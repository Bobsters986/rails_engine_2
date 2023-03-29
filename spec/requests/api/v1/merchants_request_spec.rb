require 'rails_helper'

RSpec.describe "Merchants API", type: :request do
  before do
    create_list(:merchant, 3)
  end

  context "#index" do
    before do
      get '/api/v1/merchants'
    end

    context "when successful" do
      it "returns all merchants" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].size).to eq(3)
        expect(parsed[:data]).to be_an(Array)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end
  end

  context "#show" do
    before do
      @first_merchant = Merchant.first
      get "/api/v1/merchants/#{@first_merchant.id}"
    end

    context "when successful" do
      it "returns one merchant" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].size).to eq(1)
        expect(parsed[:data][:id]).to eq(@first_merchant.id.to_s)
        expect(parsed[:data][:type]).to eq('merchant')
        expect(parsed[:data][:attributes][:name]).to eq(@first_merchant.name)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for invalid merchant ID" do
        get "/api/v1/merchants/986986"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Merchant with 'id'=986986")
      end
    end
  end

  context "An Item's Merchant #show" do
    before do
      @first_merchant = Merchant.first
      @item = create(:item, merchant_id: @first_merchant.id)
      get "/api/v1/items/#{@item.id}/merchant"
    end

    context "when successful" do
      it "returns the merchant for a given item's ID" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].keys).to eq([:name])
        expect(parsed[:data][:id]).to eq(@first_merchant.id.to_s)
        expect(parsed[:data][:type]).to eq('merchant')
        expect(parsed[:data][:attributes][:name]).to eq(@first_merchant.name)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for passing an invalid item ID" do
        get "/api/v1/items/986986/merchant"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Item with 'id'=986986")
      end

      it "returns and error message for passing a string in place of an item ID integer" do
        get "/api/v1/items/hello/merchant"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Item with 'id'=hello")
      end
    end
  end
end