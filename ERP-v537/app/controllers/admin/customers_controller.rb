class Admin::CustomersController < ApplicationController
  include Pagy::Backend

  def create
    @customer = Customer.new(customer_params)
    @customer.employee_id = current_user.employee_id
    unless Customer.find_by(email: customer_params[:email]).present?
      if @customer.save
        if params[:same_as_shipping].present?
          @customer.customer_billing_address.update(first_name: @customer.customer_shipping_address.first_name, last_name: @customer.customer_shipping_address.last_name, phone: @customer.customer_shipping_address.phone, email: @customer.customer_shipping_address.email, address: @customer.customer_shipping_address.address, city: @customer.customer_shipping_address.city, country: @customer.customer_shipping_address.country, state: @customer.customer_shipping_address.state, zip: @customer.customer_shipping_address.zip)
        end
        redirect_to admin_customer_path(@customer.id), success: "Customer created successfully."
      else
        redirect_to request.referrer
      end
    else
      redirect_to request.referrer, warning: "Customer with the same email already exists."
    end
  end

  def show
    @customer = Customer.find(params[:id])
    @appointment_employee_id ||= current_user.employee_id
    @appointment_date ||= Date.today
    @appointments ||= Appointment.where(employee_id: @appointment_employee_id, appointment_date: @appointment_date)
    render :layout => "sales"
  end

  def update
    @customer = Customer.find_by(id: params[:id])
    @customer.update(customer_params)
    if params[:same_as_shipping].present?
      @customer.customer_billing_address.update(first_name: @customer.customer_shipping_address.first_name, last_name: @customer.customer_shipping_address.last_name, phone: @customer.customer_shipping_address.phone, email: @customer.customer_shipping_address.email, address: @customer.customer_shipping_address.address, city: @customer.customer_shipping_address.city, country: @customer.customer_shipping_address.country, state: @customer.customer_shipping_address.state, zip: @customer.customer_shipping_address.zip)
    end
    redirect_to request.referrer
  end

  def create_customer_lead
    @customer = Customer.new(customer_params)
    @customer.employee_id = current_user.employee_id
    unless Customer.find_by(email: customer_params[:email]).present?
      if @customer.save
        if params[:same_as_shipping].present?
          @customer.customer_billing_address.update(first_name: @customer.customer_shipping_address.first_name, last_name: @customer.last_name, address: @customer.customer_shipping_address.address, city: @customer.customer_shipping_address.city, country: @customer.customer_shipping_address.country, state: @customer.customer_shipping_address.state, zip: @customer.customer_shipping_address.zip)
        end
        redirect_to new_admin_invoice_path(customer_id: @customer.id)
      else
        redirect_to admin_sales_path
      end
    else
      redirect_to admin_sales_path, warning: "Customer with the same email already exists."
    end
  end

  def report
    @orders = Order.where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").where(employee_id: params[:employee_id]).where("orders.created_at >= ? AND orders.created_at <= ?", Time.zone.local(params[:date][:year], params[:date][:month], 1).beginning_of_month, Time.zone.local(params[:date][:year], params[:date][:month], 1).end_of_month)
  end

  private

  def customer_params
    params.require(:customer).permit(:id, :first_name, :last_name, :phone, :email, :risk_indicator_id, :trade_name, :trade_number, :note, customer_billing_address_attributes: [:id, :first_name, :last_name, :phone, :email, :address, :city, :state, :zip, :country], customer_shipping_address_attributes: [:id, :first_name, :last_name, :phone, :email, :address, :city, :state, :zip, :country])
  end
end