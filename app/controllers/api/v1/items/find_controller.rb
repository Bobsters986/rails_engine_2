class Api::V1::Items::FindController < ApplicationController
  def index
    
    if params[:name]
      items = Item.find_by_name(params[:name])

      if items == []
        render json: {
          message: "your query could not be completed",
          errors: "No Item names match your search",
          data: []
          }
      else
        render json: ItemSerializer.new(items)
      end
    end
  end
end
