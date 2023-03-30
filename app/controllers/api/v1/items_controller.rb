class Api::V1::ItemsController < ApplicationController
  def index
    if params[:merchant_id]
      merchant = Merchant.find(params[:merchant_id])
      render json: ItemSerializer.new(merchant.items)
    else
      render json: ItemSerializer.new(Item.all)
    end
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    item = Item.new(item_params)

    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render json: {
                    message: "Item was not created. Please enter valid attributes",
                    errors: item.errors.full_messages.join(', ')
                   }, status: :bad_request
    end
  end

  def update
    item = Item.find(params[:id])

    if item.update(item_params)
      render json: ItemSerializer.new(item), status: 201
    else 
      render json: {
                    message: "your query could not be completed",
                    errors: "Merchant ID doesn't exist"
                   }, status: 404
    end
  end

  def destroy
    item = Item.find(params[:id])

    item.summon_one_item_invoices.first.destroy
    item.destroy
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end