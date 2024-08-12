class Admin::NotificationsController < ApplicationController
  before_action :set_user_notification

  def read
    redirect_url = request.referrer
    if @notification.present?
      @notification.update(read_at: Time.now) if @notification.read_at.blank?

      case @notification.params[:content]
      when "tag_comment","one_ready_to_ship","one_booked","one_shipped","cancel_request","cancel_confirm","hold_request","hold_confirm","pending_payment"
        redirect_url = admin_order_path(@notification.params[:order].name)
        if @notification.params[:content] == "pending_payment" && @notification.params[:order].name.start_with?("S")
          redirect_url = edit_admin_invoice_path(@notification.params[:order].invoice) if @notification.params[:order].invoice.present?
        end
      when "tag_issue"
        redirect_url = edit_admin_issue_path(id: @notification.params[:issue].id)
      when "tag_return"
        redirect_url = edit_admin_return_path(id: @notification.params[:return])
      when "tag_purchase"
        redirect_url = admin_purchase_path(id: @notification.params[:purchase].id)
      when "tag_product_variant"
        redirect_url = admin_product_variant_path(id: @notification.params[:product_variant])
      when "many_ready_to_ship"
        redirect_url = shipping_list_admin_orders_path(ship_status: 'ready_to_ship')
      when "many_booked"
        redirect_url = shipping_list_admin_orders_path(ship_status: 'booked')
      when "many_shipped"
        redirect_url = shipping_list_admin_orders_path(ship_status: 'shipped')
      when "arriving","arrived"
        redirect_url = edit_admin_container_path(@notification.params[:container])
      when "announcement"
        redirect_url = admin_tasks_path
      when "leave_create"
        if current_user.employee.is_director && @notification.params[:user].employee.present?
          redirect_url = time_off_request_admin_departments_path
        else
          redirect_url = leave_request_admin_department_path(current_user.employee.department_id)
        end
      when "leave_update"
        redirect_url = admin_tasks_path
      when "expense_create"
        redirect_url = expense_request_admin_departments_path
      when "expense_update"
        redirect_url = admin_tasks_path
      when "create_task", "update_task", "task_reminder"
        redirect_url = admin_tasks_path
      end
    end

    redirect_to redirect_url
  end

  private

  def set_user_notification
    @notification = Notification.find_by(id: params[:id])
  end
end
