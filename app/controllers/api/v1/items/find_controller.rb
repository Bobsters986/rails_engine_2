class Api::V1::Items::FindController < ApplicationController
  before_action :valid_parameters_check

  def index
    if params[:min_price] && params[:max_price]
      render json: ItemSerializer.new(Item.in_between_prices(params[:min_price], params[:max_price]))
    elsif params[:min_price]
      render json: ItemSerializer.new(Item.price_greater_or_eq(params[:min_price]))
    elsif params[:max_price]
      render json: ItemSerializer.new(Item.price_less_or_eq(params[:max_price]))
    elsif params[:name]
      search_by_name
    end
  end

  private

  def valid_parameters_check
   if params[:name] && (params[:max_price] || params[:min_price]) || (params[:min_price].to_f < 0 || params[:max_price].to_f < 0)
    render json: { errors: "Please enter valid parameters"}, status: 400
   end
  end

  def search_by_name
    items = Item.find_by_name(params[:name])
    if items.empty?
      render json: { errors: "No Item names match your search", data: [] }
    else
      render json: ItemSerializer.new(items)
    end
  end
end
