require 'rails_helper'

RSpec.describe "Items API", type: :request do
  context "#index" do
    before do
      create_list(:item, 3)

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
      create_list(:item, 3)

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
        expect(parsed[:errors]).to eq("Couldn't find Item with 'id'=986986")
      end

      it "returns an error message for string instead of integer" do
        get "/api/v1/items/hello"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Item with 'id'=hello")
      end
    end
  end

  context "#create" do
    before do
      create_list(:item, 3)

      @merchant = create(:merchant)

      @item_params = ({ id: 18,
                       name: "Thing-a-ma-gig",
                       description: "This is a doo-dad",
                       unit_price: 99.99,
                       merchant_id: @merchant.id
                    })
      @headers = {"CONTENT_TYPE" => "application/json"}
    end
    
    context "when successful" do
      it "creates a new item" do
        expect(Item.count).to eq(3)

        post "/api/v1/items", headers: @headers, params: @item_params, as: :json
        @created_item = Item.last

        expect(response).to be_successful
        expect(response).to have_http_status(201)
        expect(Item.count).to eq(4)

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed[:data][:id]).to eq(@created_item.id.to_s)
        expect(parsed[:data][:type]).to eq('item')
        expect(parsed[:data][:attributes][:name]).to eq(@created_item.name)
        expect(parsed[:data][:attributes][:description]).to eq(@created_item.description)
        expect(parsed[:data][:attributes][:unit_price]).to eq(@created_item.unit_price)
        expect(parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][:attributes][:merchant_id]).to eq(@created_item.merchant_id)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for missing attributes, or if unit price is not a number" do
        bad_params = ({ name: " ",
                        description: " ",
                        unit_price: "hello",
                        merchant_id: " "
                      })

        post "/api/v1/items", headers: @headers, params: bad_params, as: :json
        parsed = JSON.parse(response.body, symbolize_names: true)
        
        expect(response).to have_http_status(400)
        expect(parsed[:message]).to eq("Item was not created. Please enter valid attributes")
        expect(parsed[:errors]).to eq("Name can't be blank, Description can't be blank, Unit price is not a number, Merchant can't be blank, Merchant must exist")
      end

      it "should ignore any attributes sent by the user which are not allowed" do
        extra_params = ({ name: "Thing-a-ma-gig",
                        description: "This is a doo-dad",
                        unit_price: 99.99,
                        merchant_id: @merchant.id,
                        pizza: "Pepperoni",
                        nonsense: "Really just preposterous"
                      })

        post "/api/v1/items", headers: @headers, params: extra_params, as: :json
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(201)
        expect(parsed[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed[:data][:attributes].keys).to_not eq([:name, :description, :unit_price, :merchant_id, :pizza, :nonsense])
      end
    end
  end

  context "#destroy" do
    before do
      create_list(:item, 3)

      @merchant = create(:merchant)

      @item_params = ({ id: 18,
                       name: "Thing-a-ma-gig",
                       description: "This is a doo-dad",
                       unit_price: 99.99,
                       merchant_id: @merchant.id
                    })
      @headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: @headers, params: @item_params, as: :json

      @created_item = Item.last
    end

    context "when successful" do
      it "destroys an item" do
        expect(Item.count).to eq(4)

        delete "/api/v1/items/#{@created_item.id}"

        expect(response).to be_successful
        expect(response).to have_http_status(204)

        expect(Item.count).to eq(3)
        expect{Item.find(@created_item.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "#update" do
    before do
      create_list(:item, 3)

      @merchant = create(:merchant)
      @id = create(:item).id
      @previous_name = Item.last.name
      @previous_description = Item.last.description
      @previous_price = Item.last.unit_price

      @item_params = ({ 
                       name: "Thing-a-ma-gig",
                       description: "This is a doo-dad",
                       unit_price: 99.99,
                       merchant_id: @merchant.id
                    })
      @headers = {"CONTENT_TYPE" => "application/json"}
    end

    context "when successful" do
      it "updates an item" do
        patch "/api/v1/items/#{@id}", headers: @headers, params: @item_params, as: :json

        updated_item = Item.find_by(id: @id)

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(response).to have_http_status(201)

        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed[:data][:id]).to eq(updated_item.id.to_s)
        expect(parsed[:data][:type]).to eq('item')
        expect(parsed[:data][:attributes][:name]).to eq(updated_item.name)
        expect(parsed[:data][:attributes][:description]).to eq(updated_item.description)
        expect(parsed[:data][:attributes][:unit_price]).to eq(updated_item.unit_price)
        expect(parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][:attributes][:merchant_id]).to eq(updated_item.merchant_id)

        expect(parsed[:data][:attributes][:name]).to_not eq(@previous_name)
        expect(parsed[:data][:attributes][:description]).to_not eq(@previous_description)
        expect(parsed[:data][:attributes][:unit_price]).to_not eq(@previous_price)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for invalid id" do
        patch "/api/v1/items/986986"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Item with 'id'=986986")
      end

      it "returns an error message for bad merchant_id" do
        bad_params = ({ 
          name: "Thing-a-ma-gig",
          description: "This is a doo-dad",
          unit_price: 99.99,
          merchant_id: 99999
        })

        patch "/api/v1/items/#{@id}", headers: @headers, params: bad_params, as: :json

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:message]).to eq("your query could not be completed")
        expect(parsed[:errors]).to eq("Merchant ID doesn't exist")
      end
    end
  end

  context "A Merchant's items #index" do
    before do
      @merchant1 = create(:merchant)

      create_list(:item, 5, merchant_id: @merchant1.id)

      get "/api/v1/merchants/#{@merchant1.id}/items"
    end

    context "when successful" do
      it "returns all items a merchant" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(@merchant1.items.size).to eq(5)
        expect(parsed[:data].size).to eq(5)
        expect(parsed[:data]).to be_an(Array)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
        expect(parsed[:data][0][:attributes][:name]).to eq(Item.first.name)
        expect(parsed[:data][0][:attributes][:description]).to eq(Item.first.description)
        expect(parsed[:data][0][:attributes][:unit_price]).to eq(Item.first.unit_price)
        expect(parsed[:data][0][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][0][:attributes][:merchant_id]).to eq(Item.first.merchant_id)
      end
    end

    context "when UNsuccessful" do
      it "returns an error message for invalid merchant id" do
        get "/api/v1/merchants/99999/items"

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:errors]).to eq("Couldn't find Merchant with 'id'=99999")
      end
    end
  end
end