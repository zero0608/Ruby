class Admin::FactoriesController < ApplicationController
  before_action :find_factory, only: [:edit, :update, :destroy]

  def index
    @factories = Factory.all
  end

  def new
    @factory = Factory.new
  end

  def create
    @factory = Factory.new(factory_params)
    if @factory.save
      redirect_to admin_factories_path
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
    if @factory.update(factory_params)
      redirect_to admin_factories_path, success: "Factory updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @factory.destroy
    redirect_to admin_factories_path
  end

  private

  def find_factory
    @factory = Factory.find_by(id: params[:id])
  end

  def factory_params
    params.require(:factory).permit(:name)
  end
end