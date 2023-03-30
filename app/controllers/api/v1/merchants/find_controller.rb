class Api::V1::Merchants::FindController < ApplicationController
  def show
    merchant = Merchant.find_by_name(params[:name])
    
    if merchant.nil?
      render json: {
                    message: "your query could not be completed",
                    errors: "No Merchant names match your search",
                    data: {}
                   }
    else
      render json: MerchantSerializer.new(merchant)
    end
  end
end