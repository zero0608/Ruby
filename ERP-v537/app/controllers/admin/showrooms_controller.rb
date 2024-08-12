class Admin::ShowroomsController < ApplicationController
  before_action :find_showroom, only: [:edit, :update, :destroy]

  def index
    if current_user.user_group.admin_view
      @showrooms = Showroom.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    if current_user.user_group.admin_cru
      @showroom = Showroom.new
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    @showroom = Showroom.new(showroom_params)
    if @showroom.save
      Employee.where(exit_date: nil).each do |employee|
        employee.showroom_manage_permissions.create(showroom_id: @showroom.id)
      end
      redirect_to admin_showrooms_path, success: "Showroom created successfully."
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
    if @showroom.update(showroom_params)
      redirect_to edit_admin_showroom_path(id: @showroom.id), success: "Showroom updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @showroom.destroy
    redirect_to admin_showrooms_path
  end

  private

  def find_showroom
    @showroom = Showroom.find_by(id: params[:id])
  end

  def showroom_params
    params.require(:showroom).permit(:name, :abbreviation, :store, :warehouse_id)
  end
end