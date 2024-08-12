class Admin::CategoriesController < ApplicationController
  load_and_authorize_resource
  before_action :find_category, only: [:edit, :update, :destroy]

  def index
    if current_user.user_group.admin_view
      @categories = Category.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, success: "category created successfully."
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
    if @category.update(category_params)
      redirect_to admin_categories_path, success: "category updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path
  end

  private

  def find_category
    @category = Category.find_by(id: params[:id])
  end

  def category_params
    params.require(:category).permit(:title, subcategories_attributes: [:id, :name, :category_id])
  end
end
