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
      it "returns and error message" do
        get "/api/v1/merchants/986986"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:error]).to eq("Couldn't find Merchant with 'id'=986986")
      end
    end
  end
end