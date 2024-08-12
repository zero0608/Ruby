class Admin::AppointmentsController < ApplicationController
  def index
    @calendar_appointments = Showroom.find_by(id: current_showroom["id"]).appointments
    if params[:start_date].present?
      @current_date ||= params[:start_date].to_date
    else
      @current_date ||= Date.today
    end
    @appointment_employee_id ||= current_user.employee_id
    @appointment_date ||= Date.today
    @appointments ||= Appointment.where(employee_id: @appointment_employee_id, appointment_date: @appointment_date)
    render :layout => "sales"
  end

  def create
    @appointment = Appointment.create(appointment_params)
    @appointment.update(appointment_time: params[:appointment_time].to_time)
    redirect_to admin_customer_path(@appointment.customer_id)
  end

  def create_customer_appointment
    if appointment_params[:customer_id].present?
      @appointment = Appointment.create(appointment_params)
      @appointment.update(appointment_time: params[:appointment_time].to_time)
      redirect_to admin_appointments_path
    elsif params[:email].present?
      unless Customer.find_by(email: params[:email]).present?
        @customer = Customer.create(first_name: params[:first_name], last_name: params[:last_name], phone: params[:phone], email: params[:email], trade_name: params[:trade_name], trade_number: params[:trade_number])

        @customer.create_customer_shipping_address(first_name: params[:shipping_first_name], last_name: params[:shipping_last_name], phone: params[:shipping_phone], address: params[:shipping_address], city: params[:shipping_city], country: params[:shipping_country], state: params[:shipping_state], zip: params[:shipping_zip])

        if params[:same_as_shipping].present?
          @customer.create_customer_billing_address(first_name: params[:shipping_first_name], last_name: params[:shipping_last_name], phone: params[:shipping_phone], address: params[:shipping_address], city: params[:shipping_city], country: params[:shipping_country], state: params[:shipping_state], zip: params[:shipping_zip])
        else
          @customer.create_customer_billing_address(first_name: params[:billing_first_name], last_name: params[:billing_last_name], phone: params[:billing_phone], address: params[:billing_address], city: params[:billing_city], country: params[:billing_country], state: params[:billing_state], zip: params[:billing_zip])
        end

        @appointment = Appointment.create(appointment_params)
        @appointment.update(customer_id: @customer.id, appointment_time: params[:appointment_time].to_time)
        redirect_to admin_appointments_path
      else
        redirect_to admin_appointments_path, warning: "Customer with the same email already exists."
      end
    else
      redirect_to admin_appointments_path, warning: "Missing customer information."
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:id, :customer_id, :employee_id, :showroom_id, :appointment_date, :appointment_time, :appointment_length, :appointment_type, :notes)
  end
end