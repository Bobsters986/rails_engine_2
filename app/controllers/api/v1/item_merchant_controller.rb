class Api::V1::ItemMerchantController < ApplicationController
  def show
    item = Item.find(params[:item_id])
    render json: MerchantSerializer.new(item.merchant)
  end
end