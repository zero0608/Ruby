class InvoiceReflex < ApplicationReflex
  include Pagy::Backend
  
  def invoice_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find_by(id: element.dataset[:user_id])
    invoices = @current_user.employee.invoices
    page_count = (invoices.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @invoices = pagy(invoices, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      invoices: @invoices,
      current_user: @current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#filter-invoices", html: render(partial: "invoices_list", assigns: assigns))
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
  
  def update
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    invoice.update(invoice_params)
    if invoice.waive_tax
      invoice.update(tax_amount: 0)
    else
      if invoice&.customer&.customer_shipping_address.present?
        tax = TaxRate.find_by(state: invoice&.customer&.customer_shipping_address&.state)
        if tax.present?
          invoice.update(tax_amount: tax.combined_rate)
        else
          invoice.update(tax_amount: 0)
        end
      end
    end
    if invoice&.invoice_macro_id.present?
      invoice.update(notes: invoice&.invoice_macro&.description)
    end
    if invoice.shipping_type == "Standard" || invoice.shipping_type == "Remote"
      if invoice.shipping_method == "Local Pickup" || invoice.shipping_method == "Curbside Delivery - Waive Fee" || invoice.shipping_method == "Shipping"
        invoice.update(shipping_method: nil)
      end
    elsif invoice.shipping_type == "Local"
      if invoice.shipping_method == "Shipping"
        invoice.update(shipping_method: nil)
      end
    elsif invoice.shipping_type == "Admin"
      invoice.update(shipping_method: "Shipping")
    end
  end

  def search_all
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @variants = ProductVariant.where("store ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "%#{@query}%", "%#{@query}%").where.not("sku ILIKE ? OR sku ILIKE ? OR sku ILIKE ?", "COM-%", "CST-%", "WS-%").first(10) if @query.present?

    assigns = {
      query: @query,
      variants: @variants,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_all", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_com
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @variants = ProductVariant.where("store ILIKE ? AND sku ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "COM-%", "%#{@query}%", "%#{@query}%").first(10) if @query.present?
    @products = Product.where("store ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "%#{@query}%", "%#{@query}%") if @query.present?

    assigns = {
      query: @query,
      variants: @variants,
      products: @products,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_com", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_ws
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @returns = ReturnProduct.eager_load(:line_item, :product_variant).where(store: store_type).where("return_products.quantity > 0 AND (line_items.title ILIKE ? OR line_items.sku ILIKE ? OR line_items.sku ILIKE ? OR product_variants.title ILIKE ? OR product_variants.sku ILIKE ? OR product_variants.sku ILIKE ?)", "%#{@query}%", "%#{@query}%", "WS-%#{@query}%", "%#{@query}%", "%#{@query}%", "WS-%#{@query}%").first(10) if @query.present?

    assigns = {
      query: @query,
      returns: @returns,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_ws", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_cst
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @variants = ProductVariant.where("store ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "%#{@query}%", "%#{@query}%").first(10) if @query.present?

    assigns = {
      query: @query,
      variants: @variants,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_cst", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_cem
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @products = Product.where("store ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "%#{@query}%", "%#{@query}%").first(10) if @query.present?

    assigns = {
      query: @query,
      products: @products,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_cem", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_mto
    @query = element[:value].strip
    store_type = element.dataset[:store_type]
    @variants = ProductVariant.where("store ILIKE ? AND (title ILIKE ? OR sku ILIKE ?)", store_type, "%#{@query}%", "%#{@query}%").where.not("sku ILIKE ? OR sku ILIKE ?", "COM-%", "CST-%").first(10) if @query.present?

    assigns = {
      query: @query,
      variants: @variants,
      invoice_id: element.dataset[:invoice_id]
    }

    morph :nothing
  
    cable_ready
      .inner_html(selector: "#variant-search-results", html: render(partial: "search_mto", assigns: assigns))
      .push_state()
      .broadcast
  end

  def add_invoice_line_item_all
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    invoice.invoice_line_items.create(product_variant_id: element.dataset[:variant_id], quantity: 0)
  end

  def add_invoice_line_item_com
    product = Product.find_by(id: element.dataset[:product_id])
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    if product.product_variants.where("product_variants.sku ILIKE ?", "COM-%").present?
      invoice.invoice_line_items.create(product_variant_id: product.product_variants.where("product_variants.sku ILIKE ?", "COM-%").first.id, quantity: 0, price: 0)
    else
      variant = product&.product_variants&.first&.dup
      if variant.present?
        variant&.update(title: "COM-" + product.title, price: nil, sku: "COM-" + product.sku, inventory_quantity: nil, old_inventory_quantity: nil, unit_cost: nil, slug: ("COM-" + product.title).parameterize, inventory_limit: nil, variant_fulfillable: nil, discounted_price: nil, container_count: nil, special_price: nil, m2_product_id: nil, max_limit: nil, supplier_price: nil)
        invoice.invoice_line_items.create(product_variant_id: variant.id, quantity: 0, price: 0)
      end
    end
  end

  def add_invoice_line_item_ws
    ret = ReturnProduct.find_by(id: element.dataset[:return_id])
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    if ret.line_item_id.present?
      invoice.invoice_line_items.create(product_variant_id: ret.line_item.variant_id, quantity: 0, price: 0, return_id: ret.id)
    elsif ret.product_variant_id.present?
      invoice.invoice_line_items.create(product_variant_id: ret.product_variant_id, quantity: 0, price: ret.product_variant.price, return_id: ret.id)
    end
  end

  def add_invoice_line_item_cst
    variant = ProductVariant.find_by(id: element.dataset[:variant_id])
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    if variant.sku.start_with? "CST"
      invoice.invoice_line_items.create(product_variant_id: variant.id, quantity: 0, price: 0)
    else
      new_variant = variant&.dup
      if new_variant.present?
        new_variant&.update(title: "CUSTOM-" + variant.title, price: nil, sku: "CST-" + variant.sku, inventory_quantity: nil, old_inventory_quantity: nil, unit_cost: nil, slug: ("CUSTOM-" + variant.title).parameterize, inventory_limit: nil, variant_fulfillable: nil, discounted_price: nil, container_count: nil, special_price: nil, m2_product_id: nil, max_limit: nil, supplier_price: nil)
        invoice.invoice_line_items.create(product_variant_id: new_variant.id, quantity: 0, price: 0)
      end
    end
  end

  def add_invoice_line_item_mto
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    invoice.invoice_line_items.create(product_variant_id: element.dataset[:variant_id], quantity: 0, mto: true)
  end

  def remove_invoice_line_item
    invoice_line_item = InvoiceLineItem.find_by(id: element.dataset[:item_id])
    invoice_line_item.destroy
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
  end

  def paginate
    params[:page] = element.dataset[:page].to_i
    invoices = InvoiceForBilling.all

    page_count = (invoices.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @invoices = pagy(invoices, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      invoices: @invoices
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#invoice-results", html: render(partial: "invoice_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def no_sale
    invoice = Invoice.find_by(id: element.dataset[:invoice_id])
    invoice.update(status: :no_sale)
  end

  def change_quarter
    @quarter = element.dataset[:quarter].to_i
    @year = element.dataset[:year]
  end

  def change_year
    @quarter = element.dataset[:quarter].to_i
    @year = element.value
  end

  private

  def invoice_params
    params.require(:invoice).permit(:id, :order_id, :invoice_number, :status, :notes, :discount, :discount_amount, :tax_amount, :waive_tax, :shipping_method, :employee_id, :shipping_type, :shipping_amount, :order_name, :customer_id, :source, :payment_method, :deposit, :additional_payment_method, :additional_deposit, :additional_notes, :invoice_macro_id, :no_sale_notes, :lead_note, invoice_line_items_attributes: [ :id, :quantity, :price, :additional_notes ])
  end
end