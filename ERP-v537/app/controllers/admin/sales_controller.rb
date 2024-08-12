class Admin::SalesController < ApplicationController
  def index
    @dashboard_date ||= Date.today
    @dashboard_selection ||= "leads"
    @dashboard_employee ||= current_user.employee_id
    @dashboard_sales ||= Employee.find_by(id: @dashboard_employee).orders.where("orders.created_at >= ? AND orders.created_at < ?", @dashboard_date.beginning_of_week, @dashboard_date.end_of_week)
    @dashboard_leads ||= Employee.find_by(id: @dashboard_employee).invoices.where("invoices.status = 0 AND invoices.created_at >= ? AND invoices.created_at < ?", @dashboard_date.beginning_of_week, @dashboard_date.end_of_week)
    render :layout => "sales"
  end
end