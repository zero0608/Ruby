class Admin::ReplacementsController < ApplicationController
  before_action :find_replacement, only: [:edit, :update, :destroy]

  def index
    if current_user.user_group.replacement_view
      @replacements = Replacement.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @replacement = Replacement.new
  end

  def create
    @replacement = Replacement.new(replacement_params)
    if @replacement.save
      redirect_to admin_replacements_path, success: "Replacement created successfully."
    else
      render "new"
    end
  end

  def edit
    if current_user.user_group.replacement_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @replacement.update(replacement_params)
      redirect_to admin_replacements_path, success: "Replacement updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @replacement.destroy
    redirect_to admin_replacements_path
  end

  private

  def find_replacement
    @replacement = Replacement.find_by(id: params[:id])
  end

  def replacement_params
    params.require(:replacement).permit(:product_part_id, :description, :quantity)
  end
end