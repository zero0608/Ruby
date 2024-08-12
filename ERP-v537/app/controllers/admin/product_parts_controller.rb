class Admin::ProductPartsController < ApplicationController
  before_action :find_product_part, only: [:edit, :update, :destroy]

  def index
    if current_user.user_group.admin_view
      @product_parts = ProductPart.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @product_part = ProductPart.new
  end

  def create
    @product_part = ProductPart.new(product_part_params)
    if @product_part.save
      redirect_to admin_product_parts_path, success: "Product part created successfully."
    else
      render "new"
    end
  end

  def edit
    if current_user.user_group.admin_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @product_part.update(product_part_params)
      redirect_to admin_product_parts_path, success: "Product part updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @product_part.destroy
    redirect_to admin_product_parts_path
  end

  private

  def find_product_part
    @product_part = ProductPart.find_by(id: params[:id])
  end

  def product_part_params
    params.require(:product_part).permit(:name)
  end
end