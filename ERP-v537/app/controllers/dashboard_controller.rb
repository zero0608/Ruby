class DashboardController < ApplicationController
	skip_load_and_authorize_resource
  before_action :authenticate_user!
  
  def index
    if current_user.supplier?
      redirect_to supplier_index_admin_purchases_path
    elsif current_user.warehouse?
      redirect_to outstanding_admin_warehouses_path
    elsif current_user.user_group.overview_view
      redirect_to admin_tasks_path
    else
      render "dashboard/unauthorized"
    end
  end

  def unauthorized
  end

  def redirect_store
    if params[:store] == "canada"
      case URI(request.referrer).path
        when stock_admin_orders_path
          redirect_to emca_stock_admin_orders_path
        when admin_containers_path
          redirect_to emca_container_index_admin_containers_path(time: "this_week")
        when admin_products_path
          redirect_to emca_products_admin_products_path
        else
          redirect_to request.referrer
      end
    else
      case URI(request.referrer).path
        when emca_stock_admin_orders_path
          redirect_to stock_admin_orders_path
        when emca_container_index_admin_containers_path
          redirect_to admin_containers_path(time: "this_week")
        when emca_products_admin_products_path
          redirect_to admin_products_path
        else
          redirect_to request.referrer
       end
    end
    set_store
  end

  def redirect_showroom
    redirect_to request.referrer
    set_showroom
  end
end