# frozen_string_literal: true

class PurchaseReflex < ApplicationReflex
  include Pagy::Backend

  def paginate
    params[:page] = element.dataset[:page].to_i
    update_variant
  end

  def suppler_orders
    params[:query] = element[:value].strip
    update_supplier_order
  end

  def supplier_index_paginate
    params[:page] = element.dataset[:page].to_i
    update_supplier_purchases
  end

  def pre_order_paginate
    params[:page] = element.dataset[:page].to_i
    update_pre_order
  end

  def emca_index_paginate
    params[:page] = element.dataset[:page].to_i
    update_emca_purchases
  end

  def index_paginate
    params[:page] = element.dataset[:page].to_i
    update_purchases
  end

  def paginate_item
    params[:page] = element.dataset[:page].to_i
    update_item
  end

  def search_orders
    params[:query] = element[:value].strip
    update_customer_order
  end

  def emca_search_orders
    params[:query] = element[:value].strip
    update_emca_customer_order
  end

  def search_item
    params[:query] = element[:value].strip
    update_item
  end

  def search_product
    params[:query] = element[:value].strip
    update_product
  end

  def search_variant
    params[:query] = element[:value].strip
    update_variant
  end

  def update
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @purchase = Purchase.find(element.dataset[:purchase_id])
    @purchase.update(purchase_params)
    @purchase_item = PurchaseItem.find(element.dataset[:purchase_item_id])
    Magento::UpdateOrder.new(@purchase_item.product_variant.store).update_arriving_case_1_3(@purchase_item.product_variant) if @purchase_item.product_variant_id.present? && !(@purchase_item.line_item_id.present?)
    @purchase_item.line_item.update(status: @purchase_item.status) if @purchase_item.line_item.present?
    LineItem.where(purchase_item_id: @purchase_item.id, purchase_id: @purchase.id).update_all(status: @purchase_item.status) if LineItem.where(purchase_item_id: @purchase_item.id, purchase_id: @purchase.id).present?
    @purchase_item.audits.where(user_id: nil).destroy_all
  end
  
  def quantity
    @purchase = Purchase.find(element.dataset[:purchase_id])
    @purchase.update(purchase_params)
  end

  def filter_item
    line_items = LineItem.joins(:order).where(order_from: nil, status: :not_started, orders: { store: current_store }).where.not(orders: {order_type: 'SW'})
    line_items = line_items.where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee")

    if element.dataset[:supplier].present?
      line_items = line_items.eager_load(:variant).where(product_variants: { supplier_id: element.dataset[:supplier]})
    end
     
    @line_items = line_items

    assigns = {
      order_by: @order_by,
      direction: @direction,
      line_items: @line_items
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-item-result", html: render(partial: "search_item", assigns: assigns))
      .push_state()
      .broadcast
  end
  
  private

  def purchase_params
    params.require(:purchase).permit(:id, :store, :order_id, :supplier_id, purchase_items_attributes: [:state, :warehouse_id, :line_item_id, :quantity, :product_id, :product_variant_id, :purchase_type, :status, :id, :etc_date, :comment_description])
  end

  def update_supplier_purchases
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    @current_user = User.find(element.dataset[:user_id])
    purchases = Purchase.eager_load(:purchase_items, :supplier).where(supplier: @current_user.supplier)
    

    page_count = (purchases.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @purchases = pagy(purchases, page: @page)

    assigns = {
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      purchases: @purchases,
      current_user: @current_user
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-list-results-supplier", html: render(partial: "supplier_purchases", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_emca_purchases
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    @current_user = User.find(element.dataset[:user_id])
    purchases = Purchase.eager_load(:purchase_items, :supplier).where(store: 'canada')

    page_count = (purchases.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @purchases = pagy(purchases, page: @page)

    assigns = {
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      purchases: @purchases,
      current_user: @current_user
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    # morph :nothing

    cable_ready
      .inner_html(selector: "#emca-purchase-list-results", html: render(partial: "emca_purchase_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_purchases
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    @current_user = User.find(element.dataset[:user_id])
    if @current_user.supplier?
      purchases = Purchase.eager_load(:purchase_items, :supplier).all
    else
      purchases = Purchase.eager_load(:purchase_items, :supplier).where(store: 'us')
    end

    page_count = (purchases.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @purchases = pagy(purchases, page: @page)

    assigns = {
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      purchases: @purchases,
      current_user: @current_user
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    # morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-list-results", html: render(partial: "purchase_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_pre_order
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])

    purchase_items = PurchaseItem.eager_load(:purchase).joins(:purchase).where(purchases: { store: current_store})
    purchase_items = purchase_items.eager_load(:containers).joins(:containers).where.not(containers: {status: :arrived}, containers: {arriving_to_dc: nil})

    page_count = (purchase_items.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @purchase_items = pagy(purchase_items, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      purchase_items: @purchase_items
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#pre-odrer-list-results", html: render(partial: "pre_order_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_supplier_order
    @query = params[:query].upcase
    if @query.include? "TUS"
      @query = @query.gsub("TUS","")
    elsif @query.include? "TCA"
      @query = @query.gsub("TCA","")
    end
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    current_user = User.find(element.dataset[:user_id])
    purchases = Purchase.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier)
    purchases = Purchase.where(id: "#{@query}".to_i) if @query.present?
    # line_items = LineItem.joins(:order).where("(orders.name ILIKE ?)","%#{@query}%") if @query.present?
    current_user = User.find(element.dataset[:user_id])
    purchases = Purchase.joins(:product_variants).where("(product_variants.sku ILIKE ?)","%#{@query}%") if @query.present? && !(purchases.present?)

    purchases = Purchase.joins(:line_items).where("(line_items.sku ILIKE ?)","%#{@query}%") if @query.present? && !(purchases.present?)
    purchases = Purchase.joins(:orders).where("(orders.name ILIKE ?)","%#{@query}%") if @query.present? && !(purchases.present?)
    # purchases = purchases.eager_load(:purchase_items, :supplier).where(supplier_id: current_user.id) if current_user.supplier?
    purchases = purchases.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier) if purchases.present?

    page_count = (purchases.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @purchases = pagy(purchases, page: @page)

    assigns = {
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      purchases: @purchases.uniq,
      current_user: current_user
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-list-results-supplier", html: render(partial: "supplier_purchases", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_customer_order
    @query = params[:query]
    current_user = User.find(element.dataset[:user_id])
    @purchases = Purchase.where(store: "us").eager_load(:product_variants, :line_items, :orders).where("(purchases.id = ?) OR (product_variants.sku ILIKE ?) OR (line_items.sku ILIKE ?) OR (orders.name ILIKE ?)", @query.upcase.gsub("TUS", "").to_i, "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    assigns = {
      purchases: @purchases,
      current_user: current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-header-results", html: render(partial: "purchase_search_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_emca_customer_order
    @query = params[:query]
    current_user = User.find(element.dataset[:user_id])
    @purchases = Purchase.where(store: "canada").eager_load(:product_variants, :line_items, :orders).where("(purchases.id = ?) OR (product_variants.sku ILIKE ?) OR (line_items.sku ILIKE ?) OR (orders.name ILIKE ?)", @query.upcase.gsub("TCA", "").to_i, "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?

    assigns = {
      purchases: @purchases,
      current_user: current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-header-results", html: render(partial: "purchase_search_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_item
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    line_items = LineItem.joins(:order).where(order_from: nil, status: :not_started, orders: { store: current_store }).where.not(orders: {order_type: 'SW'})
    line_items = line_items.where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee")
    # line_items = line_items.where("(sku ILIKE ?)","%#{@query}%") if @query.present?
    line_items = line_items.joins(:order).where("(orders.name ILIKE ?)","%#{@query}%") if @query.present?
     
    # page_count = (line_items.count / Pagy::VARS[:items].to_f).ceil

    # @page = (params[:page] || 1).to_i
    # @page = page_count if @page > page_count
    # @page = 1 if @page < 1
    # @pagy, @line_items = pagy(line_items, page: @page)
    @line_items = line_items

    assigns = {
      order_by: @order_by,
      direction: @direction,
    #   page: @page,
    #   pagy: @pagy,
      line_items: @line_items
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:line_items, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-item-result", html: render(partial: "search_item", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_product
    @purchase = Purchase.find(params[:id])
    @query = params[:query]
    current_store = element.dataset[:store_type]
    variants = ProductVariant.where(store: current_store).where("(product_variants.title ILIKE ?) or (product_variants.sku ILIKE ?)","%#{@query}%","%#{@query}%").first(20) if @query.present?
    
    # variants = variants.where("(product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.store ILIKE ?)","Default Title", "%#{"warranty"}%","Get Your Swatches","Get Your Swatches",current_store) if !(variants.nil?)
    

    @variants = variants
    @current_store = current_store

    assigns = {
      variants: @variants,
      purchase: @purchase,
      current_store: @current_store
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-product-result", html: render(partial: "search_product", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_variant
    @purchase = Purchase.find(params[:id])
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    variants = ProductVariant.where(ProductVariant.arel_table[:inventory_limit].gt(ProductVariant.arel_table[:inventory_quantity]))
    variants = variants.where(store: current_store, variant_fulfillable: true)
    variants = variants.where("(product_variants.title ILIKE ?) or (sku ILIKE ?)","%#{@query}%","%#{@query}%") if @query.present?

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
      variants: @variants,
      purchase: @purchase
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#purchase-order-result", html: render(partial: "search_variant", assigns: assigns))
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
