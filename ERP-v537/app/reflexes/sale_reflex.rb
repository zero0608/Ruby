class SaleReflex < ApplicationReflex
  def search_product
    @query = element[:value].strip
    @current_store = element.dataset[:current_store]
    @warehouse_id = element.dataset[:warehouse_id]
    @warehouse_variants = WarehouseVariant.where(store: @current_store, warehouse_id: @warehouse_id)
    @warehouse_variants = @warehouse_variants.eager_load(:product_variant).where("(product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%").where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%").first(10) if @query.present?

    assigns = {
      query: @query,
      current_store: @current_store,
      warehouse_variants: @warehouse_variants
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#product-results", html: render(partial: "admin/sales/search_product", assigns: assigns))
      .push_state()
      .broadcast    
  end

  def update_dashboard_date
    @dashboard_date = element[:value].to_date
    @dashboard_selection = element.dataset[:selection]
    @dashboard_employee = element.dataset[:employee]
  end

  def update_dashboard_selection
    @dashboard_date = element.dataset[:date].to_date
    @dashboard_selection = element.dataset[:selection]
    @dashboard_employee = element.dataset[:employee]
  end

  def order_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find_by(id: element.dataset[:user_id])
    orders = @current_user.employee.orders
    page_count = (orders.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @orders = pagy(orders, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      orders: @orders,
      current_user: @current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-sales", html: render(partial: "sales_list", assigns: assigns))
      .push_state()
      .broadcast
  end

  def order_search
    @query = element[:value].strip
    @order_search = User.find_by(id: element.dataset[:user_id]).employee.orders.eager_load(:customer).where("orders.name ILIKE ? OR customers.first_name ILIKE ? OR customers.last_name ILIKE ? OR concat(customers.first_name, ' ', customers.last_name) ILIKE ?", "%#{ @query }%", "%#{ @query }%", "%#{ @query }%", "%#{ @query }%").first(20)

    assigns = {
      query: @query,
      order_search: @order_search
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#customer-search-results", html: render(partial: "sales_result", assigns: assigns))
      .push_state()
      .broadcast
  end

end