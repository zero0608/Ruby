class Admin::ShippingRatesController < ApplicationController
  def index
    @local_shipping_rates = LocalShippingRate.where(store: current_store).all
    @remote_shipping_rates = RemoteShippingRate.where(store: current_store).all
    @standard_shipping_rates = StandardShippingRate.where(store: current_store).all
    @local_cities = LocalCity.where(store: current_store).all
  end

  def create
    if params[:remote_shipping_rate].present?
      @remote_shipping_rate = RemoteShippingRate.create(remote_shipping_rate_params)
    elsif params[:local_shipping_rate].present?
      @local_shipping_rate = LocalShippingRate.create(local_shipping_rate_params)
    elsif params[:standard_shipping_rate].present?
      @standard_shipping_rate = StandardShippingRate.create(standard_shipping_rate_params)
    end
    redirect_to admin_shipping_rates_path
  end

  def remote_shipping_rate
    @remote_shipping_rate = RemoteShippingRate.new
  end

  def local_shipping_rate
    @local_shipping_rate = LocalShippingRate.new
  end

  def standard_shipping_rate
    @standard_shipping_rate = StandardShippingRate.new
  end

  def update_rate
    if params[:shipping] == 'standard'
      @update_rate = StandardShippingRate.find(params[:rate])
    elsif params[:shipping] == 'remote'
      @update_rate = RemoteShippingRate.find(params[:rate])
    elsif params[:shipping] == 'local'
      @update_rate = LocalShippingRate.find(params[:rate])
    end
  end

  def delete_rate
    if params[:shipping] == "standard"
      @rate = StandardShippingRate.find(params[:rate])
    elsif params[:shipping] == "remote"
      @rate = RemoteShippingRate.find(params[:rate])
    elsif params[:shipping] == "local"
      @rate = LocalShippingRate.find(params[:rate])
    end
    @rate.destroy
    redirect_to admin_shipping_rates_path
  end

  def update
    if params[:local_shipping_rate].present?
      @local_shipping_rate = LocalShippingRate.find(params[:format])
      @local_shipping_rate.update(local_shipping_rate_params)
    elsif params[:standard_shipping_rate].present?
      @standard_shipping_rate = StandardShippingRate.find(params[:format])
      @standard_shipping_rate.update(standard_shipping_rate_params)
    elsif params[:remote_shipping_rate].present?
      @remote_shipping_rate = RemoteShippingRate.find(params[:format])
      @remote_shipping_rate.update(remote_shipping_rate_params)
    end
    redirect_to admin_shipping_rates_path
  end

  private

  def remote_shipping_rate_params
    params.require(:remote_shipping_rate).permit(:order_min_price, :order_max_price, :store, :shipping_method, :discount)
  end

  def local_shipping_rate_params
    params.require(:local_shipping_rate).permit(:order_min_price, :order_max_price, :store, :shipping_method, :discount)
  end

  def standard_shipping_rate_params
    params.require(:standard_shipping_rate).permit(:order_min_price, :order_max_price, :store, :shipping_method, :discount)
  end
end
