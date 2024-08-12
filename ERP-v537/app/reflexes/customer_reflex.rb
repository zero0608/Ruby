class CustomerReflex < ApplicationReflex
  def update
    @customer = Customer.find_by(id: element.dataset[:customer_id])
    @customer.update(customer_params)

    if @customer.risk_indicator_id.present?
      @customer.orders.where.not(status: :completed).update_all(status: @customer.risk_indicator.assigned_status)
    end
  end

  def search_customer
    params[:query] = element[:value].strip
    update_customer
  end

  def search_customer_lead
    params[:query] = element[:value].strip
    @query = params[:query]
    @customer_leads = Customer.where("(customers.first_name ILIKE ?) OR (customers.last_name ILIKE ?) OR (CONCAT(customers.first_name,' ',customers.last_name) ILIKE ?) OR (customers.phone ILIKE ?) OR (customers.email ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    assigns = {
      query: @query,
      customer_leads: @customer_leads
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#customer-lead-results", html: render(partial: "admin/customers/customer_lead_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  private

  def customer_params
    params.require(:customer).permit(:id, :phone, :email, :risk_indicator_id, :trade_name, :trade_number, :note, customer_billing_address_attributes: [:id, :address, :city, :state, :zip, :country], customer_shipping_address_attributes: [:id, :first_name, :last_name, :phone, :email, :address, :city, :state, :zip, :country])
  end

  def update_customer
    @query = params[:query]
    customers = Customer.where("(customers.first_name ILIKE ?) OR (customers.last_name ILIKE ?) OR (CONCAT(customers.first_name,' ',customers.last_name) ILIKE ?) OR (customers.phone ILIKE ?) OR (customers.email ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%").first(10) if @query.present?

    @customers = customers

    assigns = {
      query: @query,
      customers: @customers
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#customer-results", html: render(partial: "admin/customers/search_results", assigns: assigns))
      .push_state()
      .broadcast
  end
end