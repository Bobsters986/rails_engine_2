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

        expect(parsed[:data].count).to eq(3)
        
        expect(parsed[:data]).to be_an(Array)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end
  end

  context "#show" do
    before do
      get '/api/v1/merchants'
    end

    context "when successful" do
      it "returns one merchant" do
        expect(response).to be_successful

      end
    end
  end
end