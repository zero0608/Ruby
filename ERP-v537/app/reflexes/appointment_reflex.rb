class AppointmentReflex < ApplicationReflex
  def update_calendar_date
    @current_date = element.dataset[:date].to_date
  end

  def update_appointment_employee
    @appointment_employee_id = element.value
  end

  def update_appointment_date
    @appointment_date = element.value.to_date
  end

  def search_customer_appointment
    params[:query] = element[:value].strip
    @query = params[:query]
    @customer_appointments = Customer.where("(customers.first_name ILIKE ?) OR (customers.last_name ILIKE ?) OR (CONCAT(customers.first_name,' ',customers.last_name) ILIKE ?) OR (customers.phone ILIKE ?) OR (customers.email ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    assigns = {
      query: @query,
      customer_appointments: @customer_appointments
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#customer-appointment-results", html: render(partial: "admin/appointments/customer_appointment_results", assigns: assigns))
      .push_state()
      .broadcast
  end
end