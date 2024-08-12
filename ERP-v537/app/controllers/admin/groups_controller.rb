class Admin::GroupsController < ApplicationController
  load_and_authorize_resource :UserGroup
  before_action :find_user_group, only: [:edit, :update, :destroy]


  def index
    if current_user.user_group.admin_view
      @user_groups = UserGroup.all.where.not(name: 'Default')
      UserGroup.all.each do |g|
        unless g.warehouse_permissions.present?
          Warehouse.all.each do |warehouse|
            g.warehouse_permissions.create(warehouse_id: warehouse.id)
          end
        end
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    if current_user.user_group.admin_cru
      @user_group = UserGroup.new
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    @user_group = UserGroup.new(user_group_params)
    if @user_group.save
      Warehouse.all.each do |warehouse|
        @user_group.warehouse_permissions.create(warehouse_id: warehouse.id)
      end
      redirect_to admin_groups_path, success: "Group created successfully."
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
    if @user_group.update(user_group_params)
      redirect_to edit_admin_group_path(id: @user_group.id), success: "Group updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @user_group.destroy
    redirect_to admin_groups_path
  end

  private

  def find_user_group
    @user_group = UserGroup.find_by(slug: params[:slug])
  end

  def user_group_params
    params.require(:user_group).permit(:name, :permissions, :overview_view, :overview_cru, :orders_view, :orders_cru, :inventory_view, :inventory_cru, :inventory_admin_cru, :dc_view, :dc_cru, :issues_view, :issues_cru, :admin_view, :admin_cru, :hr_view, :hr_cru, :manager_view, :manager_cru, :billing_view, :billing_cru, :board_view, :board_cru, :replacement_view, :replacement_cru, :permission_us, :permission_ca, warehouse_permissions_attributes: [ :id, :permission ])
  end
end