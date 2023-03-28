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

  context "#show" do
    before do
      @first_item = Item.first
      get "/api/v1/items/#{@first_item.id}"
    end

    context "when successful" do
      it "returns one item" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed[:data][:id]).to eq(@first_item.id.to_s)
        expect(parsed[:data][:type]).to eq('item')
        expect(parsed[:data][:attributes][:name]).to eq(@first_item.name)
        expect(parsed[:data][:attributes][:description]).to eq(@first_item.description)
        expect(parsed[:data][:attributes][:unit_price]).to eq(@first_item.unit_price)
        expect(parsed[:data][:attributes][:merchant_id]).to eq(@first_item.merchant_id)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for invalid id" do
        get "/api/v1/items/986986"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:error]).to eq("Couldn't find Item with 'id'=986986")
      end

      it "returns an error message for string instead of integer" do
        get "/api/v1/items/hello"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:error]).to eq("Couldn't find Item with 'id'=hello")
      end
    end
  end
end