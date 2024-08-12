class Admin::PalletsController < ApplicationController
  load_and_authorize_resource
  before_action :find_pallet, only: [:edit, :update, :destroy]
  def index
    if current_user.user_group.admin_view
      @pallets = Pallet.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @pallet = Pallet.new
  end

  def create
    @pallet = Pallet.new(pallet_params)
    if @pallet.save
      redirect_to admin_pallets_path, success: "Pallet created successfully."
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
    if @pallet.update(pallet_params)
      redirect_to admin_pallets_path, success: "Pallet updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @pallet.destroy
    redirect_to admin_pallets_path
  end

  private

  def find_pallet
    @pallet = Pallet.find_by(id: params[:id])
  end

  def pallet_params
    params.require(:pallet).permit(:pallet_size, :pallet_height, :pallet_width,
    :pallet_length, :pallet_weight)
  end
end
