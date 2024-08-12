# frozen_string_literal: true

class ProductReflex < ApplicationReflex
  include Pagy::Backend

  def select_category
    @category = session[:category] = Category.find(element[:value])
  end

  def paginate
    params[:page] = element.dataset[:page].to_i
    if params[:action] == "inventory"
      update_stock
    else
      update_client
    end
  end

  def search
    if params[:action] == "inventory"
      params[:query] = element[:value].strip
      update_stock
    else
      params[:query] = element[:value].strip
      update_product
    end
  end

  def assign_variant
    params[:query] = element[:value].strip
    update_variant
  end

  def emca_paginate
    params[:page] = element.dataset[:page].to_i
    if params[:action] == "emca_inventory"
      update_emca_stock
    else
      update_emca_client
    end
  end

  def emca_search
    if params[:action] == "emca_inventory"
      params[:query] = element[:value].strip
      update_emca_stock
    else
      params[:query] = element[:value].strip
      update_emca_client
    end
  end

  def build_carton
    product = Product.find_by(id: element.dataset[:product_id])
    carton_detail = product.carton_details.create(index: product.carton_details.present? ? product.carton_details.maximum(:index) + 1 : 1)
    product.product_variants.each do |variant|
      variant.cartons.create(received_quantity: variant.received_quantity, to_do_quantity: variant.to_do_quantity, carton_detail_id: carton_detail.id)
    end
  end

  def destroy_carton
    carton_detail = CartonDetail.find_by(id: element.dataset[:carton_id])
    carton_detail.destroy if carton_detail.present?
  end

  private

  def update_product
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    current_store = element.dataset[:store_type]
    products = Product.where(store: current_store, m2_original: nil)
    # products = Product.where("products.store = 'us' AND (products.m2_original IS NULL OR products.sku NOT LIKE ?)", "6%")
    products = products.eager_load(:product_variants).where("(products.var_sku ILIKE ?) or (products.sku ILIKE ?) or (products.title ILIKE ?) or (product_variants.sku ILIKE ?)","%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    # products = products.search(@query) if @query.present?
    page_count = (products.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @products = pagy(products, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      products: @products,
      current_store: current_store
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:products, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#product-search-header-results", html: render(partial: "product_search_header_results", assigns: assigns))
      .push_state(url: uri.to_s)
      .broadcast
  end

  def update_client
    @query = params[:query]
    current_store = 'us'
    products = Product.where(store: current_store, m2_original: nil).order(:sku)
    products = products.where("(var_sku ILIKE ?) or (sku ILIKE ?) or (title ILIKE ?)","%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    page_count = (products.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @products = pagy(products, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      products: @products,
      current_store: current_store
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:products, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#product-search-results", html: render(partial: "search_results", assigns: assigns))
      .push_state(url: uri.to_s)
      .broadcast
  end

  def update_stock
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    @current_user = User.find(element.dataset[:user_id]) if User.find(element.dataset[:user_id]).present?

    # variants = ProductVariant.joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(@order_by => @direction)
    variants = ProductVariant.where("(product_variants.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)",'us', "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(@order_by => @direction)
    variants = variants.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%", "%#{@query}%") if @query.present?
    page_count = (variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @variants = pagy(variants, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      variants: @variants,
      current_user: @current_user
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:variants, :pagy).to_query

    morph :nothing
    
    cable_ready
    .inner_html(selector: "#stock_result", html: render(partial: "stock_result", assigns: assigns))
    .push_state(url: uri.to_s)
    .broadcast

  end

  def update_variant
    @query = params[:query]
    @product = Product.find(element.dataset[:product_id]) 
    variants = ProductVariant.all
    variants = variants.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%", "%#{@query}%") if @query.present?
    @variants = variants    

    assigns = {
      query: @query,
      variants: @variants,
      product: @product
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:variants, :pagy).to_query

    morph :nothing
    
    cable_ready
    .inner_html(selector: "#product-assign-results", html: render(partial: "assign_results", assigns: assigns))
    .push_state(url: uri.to_s)
    .broadcast

  end

  def update_emca_client
    @query = params[:query]
    current_store = 'canada'
    products = Product.where(store: current_store, m2_original: nil).order(:sku)
    products = products.where("(var_sku ILIKE ?) or (sku ILIKE ?) or (title ILIKE ?)","%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    page_count = (products.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @products = pagy(products, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      products: @products,
      current_store: current_store
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:products, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#product-search-header-results", html: render(partial: "product_search_header_results", assigns: assigns))
      .push_state(url: uri.to_s)
      .broadcast
  end

  def update_emca_stock
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    @current_user = User.find(element.dataset[:user_id]) if User.find(element.dataset[:user_id]).present?

    # variants = ProductVariant.joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(@order_by => @direction)
    variants = ProductVariant.where("(product_variants.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)",'canada', "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(@order_by => @direction)
    variants = variants.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%", "%#{@query}%") if @query.present?
    page_count = (variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @variants = pagy(variants, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      variants: @variants,
      current_user: @current_user
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:variants, :pagy).to_query

    morph :nothing
    
    cable_ready
    .inner_html(selector: "#emca_stock_result", html: render(partial: "emca_stock_result", assigns: assigns))
    .push_state(url: uri.to_s)
    .broadcast

  end

  def permitted_column_name(column_name)
    %w[title].find { |permitted| column_name == permitted } || "title"
  end

  def permitted_direction(direction)
    %w[asc desc].find { |permitted| direction == permitted } || "asc"
  end
end