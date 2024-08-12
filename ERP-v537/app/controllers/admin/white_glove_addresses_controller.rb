class Admin::WhiteGloveAddressesController < ApplicationController
  def index
    if current_user.user_group.admin_view
      @white_glove_addresses = WhiteGloveAddress.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @white_glove_directory = WhiteGloveDirectory.find(params[:white_glove_directory_id])
    @white_glove_address = @white_glove_directory.white_glove_addresses.new
  end

  def create
    @white_glove_address = WhiteGloveAddress.new(white_glove_address_params)
    if @white_glove_address.save
      redirect_to edit_admin_white_glove_directory_path(id: @white_glove_address.white_glove_directory_id), success: "White glove address created successfully."
    else
      render "new"
    end
  end

  def edit
    if current_user.user_group.admin_cru
      @white_glove_address = WhiteGloveAddress.find(params[:id])
      @white_glove_directory = @white_glove_address.white_glove_directory
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @white_glove_address = WhiteGloveAddress.find(params[:id])
    if @white_glove_address.update(white_glove_address_params)
      redirect_to edit_admin_white_glove_directory_path(id: @white_glove_address.white_glove_directory_id), success: "White glove address updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @white_glove_address = WhiteGloveAddress.find(params[:id])
    @white_glove_directory = @white_glove_address.white_glove_directory
    if @white_glove_address.shipping_details.any?
      flash[:alert] = "An order is still assigned to this address."
    else
      @white_glove_address.destroy
    end
    redirect_to edit_admin_white_glove_directory_path(id: @white_glove_directory.id)
  end

  private

  def white_glove_address_params
    params.require(:white_glove_address).permit(:id, :contact, :company, :address1, :address2, :city, :province, :country, :zip, :phone, :email, :notes, :delivery_notification, :receiving_hours, :white_glove_directory_id)
  end
end