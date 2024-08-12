class Admin::InventoryHistoriesController < ApplicationController
  def index
    @inventory_history = InventoryHistory.all
  end

  def new
    @inventory_history = InventoryHistory.new
  end
  

  def create
    @inventory_history = InventoryHistory.new(inventory_history_params)
    if @inventory_history.save
      redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
    else
      render 'new'
    end
  end

  private

  def inventory_history_params
    params.require(:inventory_history).permit(:id, :product_variant_id, :order_id, :user_id, :container_id,
    :event, :adjustment, :quantity, :created_at)
  end
end