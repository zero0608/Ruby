class Admin::StoreAddressesController < ApplicationController
  load_and_authorize_resource

  def index
    if current_user.user_group.admin_view
      @store_addresses = StoreAddress.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @store_address = StoreAddress.new
  end

  def create
    @store_address = StoreAddress.new(store_address_params)
    if @store_address.save
      redirect_to admin_store_addresses_path, success: "Store created successfully."
    else
      render 'new'
    end
  end

  def edit
    if current_user.user_group.admin_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @store_address.update(store_address_params)
      redirect_to admin_store_addresses_path, success: "Store updated successfully."
    else
      render "new"
    end
  end

  def destroy
    @store_address.destroy
    redirect_to admin_store_addresses_path
  end

  private

  def store_address_params
    params.require(:store_address).permit(:store, :address, :city, :state, :zip, :exchange_rate)
  end
end
