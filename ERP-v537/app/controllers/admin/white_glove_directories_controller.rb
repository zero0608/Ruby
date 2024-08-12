class Admin::WhiteGloveDirectoriesController < ApplicationController
  def index
    if current_user.user_group.admin_view
      @white_glove_directories = WhiteGloveDirectory.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @white_glove_directory = WhiteGloveDirectory.new
  end

  def create
    @white_glove_directory = WhiteGloveDirectory.new(white_glove_directory_params)
    if @white_glove_directory.save
      redirect_to admin_white_glove_directories_path, success: "White glove directory created successfully."
    else
      render "new"
    end
  end

  def edit
    @white_glove_directory = WhiteGloveDirectory.find(params[:id])
  end

  def update
    @white_glove_directory = WhiteGloveDirectory.find(params[:id])
    if @white_glove_directory.update(white_glove_directory_params)
      @white_glove_directory.white_glove_addresses.update_all(company: @white_glove_directory.company_name, country: @white_glove_directory.store)
      redirect_to admin_white_glove_directories_path, success: "White glove directory updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @white_glove_directory = WhiteGloveDirectory.find(params[:id])
    @white_glove_directory.destroy
    redirect_to admin_white_glove_directories_path
  end

  def update_packing_slip
    asdf

    #create merge_packing_slip
    @merge_packing_slip = MergePackingSlip.create(index: (MergePackingSlip.where(store: current_store).maximum(:index).nil? ? 0 : MergePackingSlip.where(store: current_store).maximum(:index)) + 1, store: current_store, order_id: params[:ship_ids].split(","))

    #update shipping_detail white glove address
    shipping_details = ShippingDetail.where(id: params[:ship_ids].split(","))
    shipping_details.update_all(white_glove_directory_id: params[:directory_id], white_glove_address_id: params[:address_id])

    redirect_to pdf_admin_orders_path(ship_status: "ready_to_ship", ship_ids: params[:ship_ids], directory_id: @white_glove_address.id, merge_id: @merge_packing_slip.id)
  end

  private

  def white_glove_directory_params
    params.require(:white_glove_directory).permit(:id, :company_name, :store)
  end
end