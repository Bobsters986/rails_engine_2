class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create(item_params)), status: 201
  end

  def update
    item = Item.find(params[:id])

    if item.update(item_params)
      render json: ItemSerializer.new(item), status: 201
    else 
      render json: {
        "message": "your query could not be completed",
        "errors": "Merchant ID doesn't exist"
      }, status: 404
    end
  end

  def destroy
    # item = Item.find(params[:id])
    # if item.invoice_items
    # end
      
    render json: Item.destroy(params[:id]), status: 204
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end