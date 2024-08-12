class Admin::LocationHistoriesController < ApplicationController
  def index
    @location_history = LocationHistory.all
  end

  def new
    @location_history = LocationHistory.new
  end
  

  def create
    @location_history = LocationHistory.new(location_history_params)
    if @location_history.save
      redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
    else
      render 'new'
    end
  end

  private

  def location_history_params
    params.require(:location_history).permit(:id, :product_variant_id, :order_id, :user_id, :container_id,
    :event, :adjustment, :quantity, :created_at)
  end
end
