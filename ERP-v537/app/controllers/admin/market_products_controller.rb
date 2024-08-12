class Admin::MarketProductsController < ApplicationController
  def update
    market_product = MarketProduct.find_by(id: params[:id])
    market_product.update(market_product_params)
    market_product.update(status: :sold)
    redirect_to stock_admin_orders_path(return_status: :marketplace)
  end

  private

  def market_product_params
    params.require(:market_product).permit(:id, :sold_value, :sold_date, :notes)
  end
end