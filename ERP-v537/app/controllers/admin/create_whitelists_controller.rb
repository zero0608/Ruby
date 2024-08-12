class Admin::CreateWhitelistsController < ApplicationController
  def index
    @whitelist_ips = CreateWhitelist.all
  end

  def new
    @whitelist_ip = CreateWhitelist.new
  end

  def create
    @whitelist_ip = CreateWhitelist.new(whitelist_params)
    if @whitelist_ip.save
      redirect_to admin_create_whitelists_path, success: "created successfully."
    else
      render 'new'
    end
  end

  def edit
    @whitelist_ip = CreateWhitelist.find(params[:id])
  end

  def update
    @whitelist_ip = CreateWhitelist.find(params[:id])
    if @whitelist_ip.update(whitelist_params)
      redirect_to admin_create_whitelists_path, success: "created successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @whitelist_ip = CreateWhitelist.find(params[:id])
    @whitelist_ip.destroy
    redirect_to admin_create_whitelists_path
  end

  private

  def whitelist_params
    params.require(:create_whitelist).permit(:ip_address, :name, :description, :status)
  end
end
