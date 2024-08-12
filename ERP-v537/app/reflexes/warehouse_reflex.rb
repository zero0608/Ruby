class WarehouseReflex < ApplicationReflex
  include Pagy::Backend
  
  def pick_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find(element.dataset[:user_id])

    @product_variants = ProductVariant.where(store: @current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil).where("product_variants.to_do_quantity > 0")
    
    page_count = (@product_variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @product_picks = pagy(@product_variants, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      current_user: @current_user,
      product_picks: @product_picks
    }

    cable_ready
      .inner_html(selector: "#pick", html: render(partial: "pick", assigns: assigns))
      .push_state()
      .broadcast
  end

  def put_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find(element.dataset[:user_id])

    @product_variants = ProductVariant.where(store: @current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil).where("product_variants.received_quantity > 0")
    
    page_count = (@product_variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @product_puts = pagy(@product_variants, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      current_user: @current_user,
      product_puts: @product_puts
    }

    cable_ready
      .inner_html(selector: "#put", html: render(partial: "put", assigns: assigns))
      .push_state()
      .broadcast
  end

  def preorder_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find(element.dataset[:user_id])

    @container_items = PurchaseItem.where(status: [:not_started, :in_production, :container_ready]).where("preorder_quantity > 0").where.not(order_id: nil).eager_load(:containers).where(containers: { store: @current_user.warehouse.store, status: [:en_route, :container_ready] })
    
    page_count = (@container_items.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @preorders = pagy(@container_items, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      current_user: @current_user,
      preorders: @preorders
    }

    cable_ready
      .inner_html(selector: "#preorder", html: render(partial: "preorder", assigns: assigns))
      .push_state()
      .broadcast
  end

  def reserve_paginate
    params[:page] = element.dataset[:page].to_i
    @current_user = User.find(element.dataset[:user_id])

    @line_items = LineItem.where("length(sku) > 2").eager_load(:order).where(status: :ready, orders: { store: @current_user.warehouse.store, order_type: "Unfulfillable" }).where.not(orders: { status: "cancel_confirmed" }).joins(:shipping_detail).where(shipping_details: { status: "not_ready" }).where("length(sku) > 2").where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%Get Your Swatches%", "%warranty%","WGS001", "HLD001", "HFE001", "Handling Fee", "Cotton", "Wheat", "velvet", "Weave", "Performance").where.not(quantity: [nil, "0"]).where(reserve: false)

    page_count = (@line_items.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @reserved = pagy(@line_items, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      current_user: @current_user,
      reserved: @reserved
    }

    cable_ready
      .inner_html(selector: "#reserve", html: render(partial: "reserve", assigns: assigns))
      .push_state()
      .broadcast
  end

  def change_active_carton
    @active_carton = Carton.find_by(id: element.dataset[:carton_id])    
  end

  def search_product
    params[:query] = element[:value].strip
    update_product
  end

  def search_sku
    params[:query] = element[:value].strip
    update_sku
  end

  def search_admin_sku
    params[:query] = element[:value].strip
    update_admin_sku
  end

  def search_location_sku
    params[:query] = element[:value].strip
    update_location_sku
  end

  def search_location
    update_location
  end

  def update_quantity
    location = CartonLocation.find_by(id: element.dataset[:location])
    location.update(quantity: element[:value].to_i)
  end

  def update_warehouse_quantity
    @warehouse_variant = WarehouseVariant.find(element.dataset[:warehouse_variant_id])
    variant = @warehouse_variant.product_variant
    adjustment = @warehouse_variant.warehouse_quantity.to_i - element.value.to_i
    @warehouse_variant.update(warehouse_quantity: element.value.to_i)
    @warehouse_variant.product_variant.update(inventory_quantity: variant.inventory_quantity.to_i - adjustment)
    InventoryHistory.create(product_variant_id: variant.id, event: "Warehouse Quantity updated", adjustment: -adjustment, quantity: variant.inventory_quantity, warehouse_adjustment: -adjustment, warehouse_quantity: @warehouse_variant.warehouse_quantity, warehouse_id: @warehouse_variant.warehouse.id)

    Magento::UpdateOrder.new(@warehouse_variant.product_variant.store).update_quantity(@warehouse_variant.product_variant)
  end

  private

  def update_product
    @current_user = User.find(element.dataset[:user_id])
    @location = ProductLocation.find(element.dataset[:location_id])
    @query = params[:query]
    variants = ProductVariant.where("lower(product_variants.sku) = ?", "#{@query.downcase}").where(store: @current_user.warehouse.store) if @query.present?    

    @variants = variants

    assigns = {
      variants: @variants,
      location: @location
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-result", html: render(partial: "search_product", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_sku
    @query = params[:query]
    @current_user = User.find(element.dataset[:user_id])
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    variants = ProductVariant.where("product_variants.received_quantity > 0 or product_variants.to_do_quantity > 0").where("(product_variants.title = ?) or (lower(product_variants.sku) = ?)","#{@query}","#{@query.downcase}").where(store: @current_user.warehouse.store) if @query.present?

    page_count = (variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @variants = pagy(variants, page: @page)

    assigns = {
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      query: @query,
      variants: @variants
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#warehouse-search-sku", html: render(partial: "search_skus", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_admin_sku
    @query = params[:query]
    @current_user = User.find(element.dataset[:user_id])
    @product_variants = ProductVariant.where("(product_variants.title ILIKE ?) OR (lower(product_variants.sku) ILIKE ?)","%#{@query}%","%#{@query.downcase}%").where(store: @current_user.warehouse.store).first(20) if @query.present?

    assigns = {
      product_variants: @product_variants
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#warehouse-search-admin-sku", html: render(partial: "search_admin_skus", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_location_sku
    @query = params[:query]
    @current_user = User.find(element.dataset[:user_id])
    @product_variants = ProductVariant.where("(product_variants.title ILIKE ?) OR (lower(product_variants.sku) ILIKE ?)","%#{@query}%","%#{@query.downcase}%").where(store: @current_user.warehouse.store).first(20) if @query.present?

    assigns = {
      product_variants: @product_variants
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#warehouse-search-location-sku", html: render(partial: "search_location_skus", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_location
    @product_locations = ProductLocation.where("(rack ILIKE ?) and (rack ILIKE ?) and (rack ILIKE ?)",params[:rack], params[:level], params[:bin])

    assigns = {
      product_locations: @product_locations
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#search-location-results", html: render(partial: "search_location", assigns: assigns))
      .push_state()
      .broadcast
  end

  def permitted_column_name(column_name)
    %w[title created_at].find { |permitted| column_name == permitted } || "created_at"
  end

  def permitted_direction(direction)
    %w[asc desc].find { |permitted| direction == permitted } || "desc"
  end

end