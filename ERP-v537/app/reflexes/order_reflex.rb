# frozen_string_literal: true

class OrderReflex < ApplicationReflex
  include Pagy::Backend

  def emca_paginate
    params[:page] = element.dataset[:page].to_i
    if params[:action] == "emca_stock"
      update_emca_stock
    else
      update_emca_client
    end
  end

  def emca_search
    params[:query] = element[:value].strip
    if params[:action] == "edit" || params[:action] == "container"
      update_order
    elsif params[:action] == "emca_stock"
      update_emca_stock
    else
      update_emca_client
    end
  end

  def search_stock
    params[:query] = element[:value].strip
    update_stock
  end

  def emca_search_stock
    params[:query] = element[:value].strip
    update_emca_stock
  end

  def search_main_stock
    params[:query] = element[:value].strip
    update_main_stock
  end

  def emca_search_main_stock
    params[:query] = element[:value].strip
    update_emca_main_stock
  end

  def paginate
    params[:page] = element.dataset[:page].to_i
    if params[:action] == "stock"
      update_stock
    else
      update_client
    end
  end

  def stock_paginate
    params[:page] = element.dataset[:page].to_i
    update_main_stock
  end

  def emca_stock_paginate
    params[:page] = element.dataset[:page].to_i
    update_emca_main_stock
  end

  def swatch_paginate
    params[:page] = element.dataset[:page].to_i
    update_main_swatch
  end

  def emca_swatch_paginate
    params[:page] = element.dataset[:page].to_i
    update_emca_main_swatch
  end

  def warehouse_paginate
    params[:page] = element.dataset[:page].to_i
    update_warehouse_stock
  end

  def index_paginate
    params[:page] = element.dataset[:page].to_i
    update_shipped_order
  end

  def not_ready_paginate
    params[:page] = element.dataset[:page].to_i
    current_store = element.dataset[:store_type]
    
    @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31'))

    @shipping_details = @shipping_details.eager_load(:line_items).joins(:line_items).where('(line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?)', 'WAREHOUSE-HOLD', 'RECONSIGNMENT-FEE', 'SHIPPING-FOR-COM', 'REMOTE-SHIPPING', 'REDELIVERY-FEE', 'HANDLING-FEE', 'STORAGE-FEE', 'WGS001', 'E-PMNT')

    @shipping_details = @shipping_details.where(status: "not_ready")

    page_count = (@shipping_details.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @shipping_details = pagy(@shipping_details, items_param: :per_page, max_items: 100)

    assigns = {
      page: @page,
      pagy: @pagy,
      current_store: current_store,
      shipping_details: @shipping_details
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#order_shippings", html: render(partial: "order_shippings", assigns: assigns, ship_params: "not_ready"))
      .push_state()
      .broadcast
  end

  def search
    params[:query] = element[:value].strip
    current_store = element.dataset[:store_type]
    update_order
  end

  def search_shipment
    @query = element[:value].strip
    current_store = element.dataset[:store_type]
    @shipping_id = element.dataset[:shipping_id]
    @shipments = ShippingDetail.where(consolidation_id: nil).eager_load(:order).where("(orders.store ILIKE ?) AND (orders.name ILIKE ?)", current_store, "%#{@query}%").first(10) if @query.present?

    assigns = {
      query: @query,
      shipping_id: @shipping_id,
      shipments: @shipments.uniq
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#shipment-search-edit-results", html: render(partial: "admin/orders/search_shipment", assigns: assigns))
      .push_state()
      .broadcast
  end

  def add_consolidate
    main_shipping = ShippingDetail.find_by(id: element.dataset[:main_shipping])
    shipping = ShippingDetail.find_by(id: element.dataset[:id])
    store = element.dataset[:store]

    if main_shipping.consolidation.present?
      shipping.update(consolidation_id: main_shipping.consolidation_id)
    else
      count = 0
      name = nil
      if main_shipping.order.store == "us"
        count = Consolidation.where(store: "us").count
        while Consolidation.find_by(name: "EMUSCON1" + count.to_s.rjust(4, "0")).present? do
          count += 1
        end
        name = "EMUSCON1" + count.to_s.rjust(4, "0")

      else
        count = Consolidation.where(store: "canada").count
        while Consolidation.find_by(name: "EMCACON1" + count.to_s.rjust(4, "0")).present? do
          count += 1
        end
        name = "EMCACON1" + count.to_s.rjust(4, "0")
      end
      
      consolidation = Consolidation.create(name: name, store: main_shipping.order.store)
      shipping.update(consolidation_id: consolidation.id)
      main_shipping.update(consolidation_id: consolidation.id)

      if main_shipping.carrier.present?
        if consolidation.shipping_details.all? { |sd| sd.status == "shipped" }
          unless consolidation.review_sections.present?
            ReviewSection.create(consolidation_id: consolidation.id, store: main_shipping.order.store, invoice_type: main_shipping.carrier.name, white_glove: false)
            consolidation.create_invoice_for_billing
          end
        end
      end
    end
  end

  def remove_consolidate
    shipping = ShippingDetail.find_by(id: element.dataset[:id])
    consolidation = shipping.consolidation
    shipping.update(consolidation_id: nil)
    consolidation.destroy if consolidation.shipping_details.count == 0
  end

  def search_link_order
    params[:query] = element[:value].strip
    @current_order = element.dataset[:current_order]
    update_link_order
  end

  def search_user
    @que = element[:value].strip
    @users = User.eager_load(employee: :department).where("(users.username ILIKE ? OR departments.name ILIKE ?)", "%#{@que}%", "%#{@que}%").where(deactivate: [false, nil]).where.not(username: ["", nil]) if @que.present?
    @departments = Department.where("departments.name ILIKE ?", "%#{@que}%") if @que.present?
    assigns = {
      query: @que,
      users: @users.uniq,
      departments: @departments.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#user-search-edit-results", html: render(partial: "admin/orders/search_user", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_task_user
    @que = element[:value].strip
    @users = User.eager_load(employee: :department).where("(users.username ILIKE ? OR departments.name ILIKE ?)", "%#{@que}%", "%#{@que}%").where(deactivate: [false, nil]).where.not(username: ["", nil]) if @que.present?
    @departments = Department.where("departments.name ILIKE ?", "%#{@que}%") if @que.present?
    assigns = {
      query: @que,
      users: @users.uniq,
      departments: @departments.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#task-user-search-edit-results", html: render(partial: "admin/tasks/search_user", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_task_order
    @que = element[:value].strip
    @orders = Order.where("name ILIKE ?", "%#{@que}%") if @que.present?
    assigns = {
      query: @que,
      orders: @orders.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#task-search-edit-results", html: render(partial: "admin/tasks/search_order", assigns: assigns))
      .push_state()
      .broadcast
  end

  def line_graph
    @orders_current_year = Order.includes(:shipping_line,:line_items,:order_adjustments).where("extract(year from orders.created_at) = ?", Date.today.year)
    @orders_previous_year = Order.includes(:shipping_line,:line_items,:order_adjustments).where("extract(year from orders.created_at) = ?", Date.today.year - 1)

    if element.dataset[:params] == "q1"
      default_count = { "JAN" => 0, "FEB" => 0, "MAR" => 0 }
      orders = @orders_current_year.where("(orders.created_at > ?) and (orders.created_at < ?)", Date.new(Date.today.year, 1).at_beginning_of_quarter, Date.new(Date.today.year, 1).at_end_of_quarter)
      series = [*1..3]
    elsif element.dataset[:params] == "q2"
      default_count = { "APR" => 0, "MAY" => 0, "JUN" => 0 }
      orders = @orders_current_year.where("(orders.created_at > ?) and (orders.created_at < ?)", Date.new(Date.today.year, 4).at_beginning_of_quarter, Date.new(Date.today.year, 4).at_end_of_quarter)
      series = [*4..6]
    elsif element.dataset[:params] == "q3"
      default_count = { "JUL" => 0, "AUG" => 0, "SEP" => 0 }
      orders = @orders_current_year.where("(orders.created_at > ?) and (orders.created_at < ?)", Date.new(Date.today.year, 7).at_beginning_of_quarter, Date.new(Date.today.year, 7).at_end_of_quarter)
      series = [*7..9]
    elsif element.dataset[:params] == "q4"
      default_count = { "OCT" => 0, "NOV" => 0, "DEC" => 0 }
      orders = @orders_current_year.where("(orders.created_at > ?) and (orders.created_at < ?)", Date.new(Date.today.year, 10).at_beginning_of_quarter, Date.new(Date.today.year, 7).at_end_of_quarter)
      series = [*10..12]
    elsif element.dataset[:params] == "current"
      default_count = { "JAN" => 0, "FEB" => 0, "MAR" => 0, "APR" => 0, "MAY" => 0, "JUN" => 0, "JUL" => 0, "AUG" => 0, "SEP" => 0, "OCT" => 0, "NOV" => 0, "DEC" => 0 }
      orders = @orders_current_year
      series = [*1..12]
    elsif element.dataset[:params] == "previous"
      default_count = { "JAN" => 0, "FEB" => 0, "MAR" => 0, "APR" => 0, "MAY" => 0, "JUN" => 0, "JUL" => 0, "AUG" => 0, "SEP" => 0, "OCT" => 0, "NOV" => 0, "DEC" => 0 }
      orders = @orders_previous_year
      series = [*1..12]
    end

    @d1 = default_count.clone
    @d2 = default_count.clone

    if orders.present?
      @d1 = @d1.merge(orders.group_by_month(:created_at, format: "%^b").count)
      series.each do |i|
        @d2[@d2.keys[series.index(i)]] = orders.where("extract(month from orders.created_at) = ?", i).sum { |order| order&.line_items&.sum {|s| (s&.price.to_i * s&.quantity.to_i)} - (order&.discount_codes.present? ? order&.discount_codes["discount_amount"]&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines["price"]&.to_f : 0) + order&.order_adjustments&.sum { |s| s&.amount&.to_f }} 
      end
    end

    assigns = {      
      d1: @d1,
      d2: @d2
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#line-graphs", html: render(partial: "line_graphs", assigns: assigns))
      .push_state()
      .broadcast
    
  end

  def status_update
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @order = Order.find_by(name: element.dataset[:name]) if element.dataset[:name].present?
    @order = Order.find_by(name: params[:name]) if params[:name].present?
    update
    Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
  end

  def update
    status = ShippingDetail.find_by(id: element.dataset[:shipping_id].to_i).status if element.dataset[:shipping_id].present?
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    current_user = User.find(element.dataset[:user_id])
    @order = Order.find_by(name: element.dataset[:name]) if element.dataset[:name].present?
    @order = Order.find_by(name: params[:name]) if params[:name].present?
    if order_params.present? && order_params[:shipping_details_attributes].present? && (order_params[:shipping_details_attributes].to_json.include? "\"status\":\"ready_to_ship\"")
      @order.shipping_details.each do |ship|
        if ship.line_items.reject { |item| (item.title.include? 'Swatch' or item.sku.length < 3) or (item.try(:sku).include? 'warranty') or (item.try(:sku) == 'WGS001') or (item.try(:sku) == 'HLD001') or (item.try(:sku) == 'HFE001') or (ShipmentCode.pluck(:sku_for_discount).include? item.try(:sku)) }.all? {|item| item.status == 'ready' }
          @order.update(order_params)
          UserNotification.with(order: @order, issue: 'nil', user: User.where(deactivate: [false, nil]).find(element.dataset[:user_id]), content: 'one_ready_to_ship', container: 'nil').deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'ready_to_ship' = ?", '1'))
        # else
        #   @order.update(order_params)
        end
      end
    else
      @order.update(order_params)
      if element.dataset[:present_status].present?
        @shipping_detail = ShippingDetail.find_by(id: element.dataset[:present_status].to_i)
        if @shipping_detail.status == "booked"
          UserNotification.with(order: @order, issue: 'nil', user: User.where(deactivate: [false, nil]).find(element.dataset[:user_id]), content: 'one_booked', container: 'nil').deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'booked' = ?", '1'))
        elsif @shipping_detail.status == "shipped"
          UserNotification.with(order: @order, issue: 'nil', user: User.where(deactivate: [false, nil]).find(element.dataset[:user_id]), content: 'one_shipped', container: 'nil').deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'shipped' = ?", '1'))
        end
      end
      @order.shipping_details.each do |sd|
        if sd.white_glove_directory_id.present? && sd.white_glove_address_id.present? && sd.white_glove_address.white_glove_directory_id != sd.white_glove_directory_id
          sd.update(white_glove_address_id: nil)
        end

        if sd.status == "shipped"
          unless sd.review_sections.where(white_glove: true).present?
            if sd.white_glove_fee.present? && (sd.white_glove_fee.to_f > 0)
              @review = ReviewSection.create(order_id: @order.id, store: @order.store, shipping_detail_id: sd.id, invoice_type: sd&.white_glove_directory&.company_name, white_glove: true)
              sd.create_invoice_for_wgd
            end
          end

          unless sd.review_sections.where(white_glove: false).present?
            if sd&.shipping_quotes&.find_by(selected: true).present? && !sd&.consolidation&.review_sections&.present?
              unless sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Local" || sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Factory to Customer" || sd&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Accurate"
                if sd.consolidation_id.present?
                  unless sd.consolidation.review_sections.present?
                    @review = ReviewSection.create(consolidation_id: sd.consolidation_id, store: @order.store, invoice_type: sd&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                    sd.consolidation.create_invoice_for_billing
                  end
                else
                  @review = ReviewSection.create(order_id: @order.id, store: @order.store, shipping_detail_id: sd.id, invoice_type: sd&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                  sd.create_invoice_for_billing
                end
              end
            end
          end
        end
      end
      @ship_detail = ShippingDetail.find_by(id: element.dataset[:shipping_id].to_i) if element.dataset[:shipping_id].present?
      if status.present? && !(@ship_detail.status == status) && @ship_detail.status == 'closed'
        @ship_detail.line_items.each do |item|
          item.update(status: :cancelled)
          @product_variant = ProductVariant.find_by(id: item.variant_id)
          # InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: 'product returned - shipment closed', adjustment: 0, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # @old_quantity = ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i
          # if item.status == 'ready' && item.variant_id.present?
          #   @product_variant.update(inventory_quantity: (item.quantity.to_i + @product_variant.inventory_quantity.to_i))
          #   @product_variant.update(to_do_quantity: (@product_variant.to_do_quantity.to_i - item.quantity.to_i))
          #   if @product_variant.cartons.present? && @product_variant.cartons.count > 1
          #     @product_variant.cartons.each do |carton|
          #       carton.update(to_do_quantity: (carton.to_do_quantity.to_i - item.quantity.to_i))
          #     end
          #   end
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          #   Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #   Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # elsif item.status == 'in_production' && item.purchase_item_id.present?
          #   purchase_item = PurchaseItem.find(item.purchase_item_id)
          #   purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          # elsif item.status == 'in_production' && PurchaseItem.find_by(line_item_id: item.id).present?
          #   @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
          #   if @purchase_item.purchase.store == 'us'
          #     @purchase_item.update(purchase_type: 'TUS')
          #   else
          #     @purchase_item.update(purchase_type: 'TCA')
          #   end
          #   @purchase_item.update(line_item_id: nil)
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          #   Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #   Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # elsif item.status == 'container_ready' && item.purchase_item_id.present?
          #   purchase_item = PurchaseItem.find(item.purchase_item_id)
          #   purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          # elsif item.status == 'container_ready' && PurchaseItem.find_by(line_item_id: item.id).present?
          #   @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
          #   if @purchase_item.containers.present?
          #     @container = @purchase_item.containers.last
          #     if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
          #       @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id,
          #                                                 line_item_id: nil).last
          #       @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
          #       @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
          #     elsif @purchase_item.purchase.store == 'us'
          #       @purchase_item.update(purchase_type: 'TUS')
          #       @purchase_item.update(line_item_id: nil)
          #     else
          #       @purchase_item.update(purchase_type: 'TCA')
          #       @purchase_item.update(line_item_id: nil)
          #     end
          #   elsif @purchase_item.purchase.store == 'us'
          #     @purchase_item.update(purchase_type: 'TUS')
          #     @purchase_item.update(line_item_id: nil)
          #   else
          #     @purchase_item.update(purchase_type: 'TCA')
          #     @purchase_item.update(line_item_id: nil)
          #   end
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          #   Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #   Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # elsif item.status == 'en_route' && item.container_id.present? && item.variant_id.present? && item.container.status != 'arrived'
          #   if item.purchase_item_id.present?
          #     purchase_item = PurchaseItem.find(item.purchase_item_id)
          #     purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
          #     InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                             user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          #     Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #     Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          #   elsif item.container_id.present?
          #     @container = Container.find(item.container_id)
          #     purchase_item = @container.purchase_items.where(product_variant_id: item.variant_id).first
          #     purchase_item = PurchaseItem.find(item.purchase_item_id)
          #     purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
          #     InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                             user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          #     Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #     Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          #   end
          # elsif item.status == 'en_route' && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present? && PurchaseItem.find_by(line_item_id: item.id).containers.where.not(containers: { status: 'arrived' }).present?
          #   @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
          #   if @purchase_item.containers.present?
          #     @container = @purchase_item.containers.last
          #     if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
          #       @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id,
          #                                                 line_item_id: nil).last
          #       @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
          #       @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
          #     elsif @purchase_item.purchase.store == 'us'
          #       @purchase_item.update(purchase_type: 'TUS')
          #       @purchase_item.update(line_item_id: nil)
          #     else
          #       @purchase_item.update(purchase_type: 'TCA')
          #       @purchase_item.update(line_item_id: nil)
          #     end
          #   elsif @purchase_item.purchase.store == 'us'
          #     @purchase_item.update(purchase_type: 'TUS')
          #     @purchase_item.update(line_item_id: nil)
          #   else
          #     @purchase_item.update(purchase_type: 'TCA')
          #     @purchase_item.update(line_item_id: nil)
          #   end
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          #   Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #   Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # elsif item.status == 'not_started' && item.purchase_item_id.present?
          #   purchase_item = PurchaseItem.find_by(line_item_id: item.id)
          #   purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
          # elsif item.status == 'not_started' && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present?
          #   @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
          #   if @purchase_item.purchase.store == 'us'
          #     @purchase_item.update(purchase_type: 'TUS')
          #   else
          #     @purchase_item.update(purchase_type: 'TCA')
          #   end
          #   @purchase_item.update(line_item_id: nil)
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
          #   Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          #   Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          # elsif item.status == 'not_started'
          #   InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id,
          #                           user_id: current_user.id, event: 'product returned - shipment closed', adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          # end
            
          # @ship_detail.line_items.update_all(status: :cancelled)
        end
      elsif status.present? && !(@ship_detail.status == status) && @ship_detail.status == 'shipped'
        create_shipment_to_m2(@order,@ship_detail)
      end
    end
    if (@order.shipping_details.all? { |ship| ship.status == 'shipped'})
      @order.update(status: 'completed')
      @order.shipping_details.each do |sp|
        sp.update(shipped_date: Date.today)if sp.shipped_date.nil?
      end
    # elsif (@order.line_items.all? { |item| item.status == 'ready'})
    #   @order.update(order_type: 'Fulfillable')
    elsif !(['cancel_confirmed', 'delayed', 'hold_confirmed', 'cancel_request', 'rejected', 'hold_request'].include? @order.status)
      @order.update(status: 'in_progress')
    end
    @order.shipping_details.each do |ship|
      if ship.pickup_start_date.present?
        ship.update(pickup_end_date: ship.pickup_start_date)
        ship.update(delivery_start_date: ship.pickup_start_date + 7.days)
        ship.update(delivery_end_date: ship.pickup_start_date + 7.days)
        ship.update(pickup_start_time: "09:00:00".to_time)
        ship.update(pickup_end_time: "16:00:00".to_time)
        ship.update(delivery_start_time: "09:00:00".to_time)
        ship.update(delivery_end_time: "16:00:00".to_time)
      end
      if ((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_i).sum) > 0) && (((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_f).sum)) >= (((@order.line_items.pluck(:price).reject(&:blank?).map(&:to_f).zip(@order.line_items.pluck(:quantity).reject(&:blank?).map(&:to_i)).map{|x, y| x.to_f * y}).sum + @order.discount_codes["discount_amount"].to_f if @order.discount_codes.present?).to_f * 0.25))
        ship.update(note: "Shipping quote exceeds 25% of the order, $#{(((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_f).sum)) - (((@order.line_items.pluck(:price).reject(&:blank?).map(&:to_f).zip(@order.line_items.pluck(:quantity).reject(&:blank?).map(&:to_f)).map{|x, y| x.to_f * y}).sum + @order.discount_codes["discount_amount"].to_f if @order.discount_codes.present?).to_f * 0.25))} over. Please get authorization before booking")
      else
        ship.update(note: nil)
      end

      # update shipping_detail carrier_id & actual_invoiced
      if ship.shipping_quotes.find_by(selected: true).present?
        ship.update(carrier_id: ship.shipping_quotes.find_by(selected: true).carrier_id)
        ship.update(actual_invoiced: ship.shipping_quotes.find_by(selected: true).amount.to_s)
      else
        ship.update(carrier_id: nil)
        ship.update(actual_invoiced: "0")
      end
      
      ship.update(white_glove_delivery: true) if ship&.white_glove_address&.company.present?
      
      #update pallet
      ship.pallet_shippings.each do |ps|
        if ps.auto_calc
          if ps.pallet.present?
            ps.update(length: ps.pallet.pallet_length, width: ps.pallet.pallet_width, height: ps.pallet.pallet_height)
          end
          ps.update(weight: ps.line_items.sum { |li| (li&.variant&.product&.carton_details&.sum { |cd| cd.weight.to_f }).to_f * li&.quantity.to_i } + (ps.pallet.present? ? ps.pallet.pallet_weight.to_f : 0))
        end
      end
    end
    @order.update(status: :hold_request) if (element.dataset[:status] == "hold_request")
    @order.shipping_details.each do |detail|
      if detail.status == "shipped" && detail.map_id.nil? && detail.carrier.present? && detail.date_booked.present? && detail.tracking_number.present?
        detail.update(tracking_url_for_ship: detail.carrier.tracking_url)
        # Magento::Project44Apis.new.track_shipment(@order,detail)
      elsif detail.map_id.nil? && detail.carrier.present? && detail.carrier.tracking_url.present?
        detail.update(tracking_url_for_ship: detail.carrier.tracking_url)
      elsif detail.map_id.nil? && detail.carrier.present? && detail.carrier.tracking_url.nil?
        detail.update(tracking_url_for_ship: nil)
      end
    end
  end

  def create_shipment_to_m2(order,shipping_detail)
    if (shipping_detail.tracking_url_for_ship.present?) && (shipping_detail.status == 'shipped')
      Magento::UpdateOrder.new(order.store).create_shipment(order,shipping_detail)
    end
  end

  def assign
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @order = Order.find_by(name: element.dataset[:name])
    @order.update(order_params)
    @line_item = LineItem.find(element.dataset[:item_id])
    @line_item.update(order_id: params[:order_id]) if params[:order_id].present?
    @line_item.update(status: Container.find(element.dataset[:container_id]).status) if element.dataset[:container_id].present?
    @line_item.update(shipping_detail_id: @line_item.order.shipping_details.first.id)
  end

  def carrier
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])

    @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where("(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)", "%warranty%", "WGS001", "HLD001", "HFE001", current_store, nil).where.not(status: "cancelled", orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not("line_items.created_at < ?", Date.parse("2021-10-31"))

    @shipping_details = @shipping_details.eager_load(:line_items).joins(:line_items).where("(line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?)", "WAREHOUSE-HOLD", "RECONSIGNMENT-FEE", "SHIPPING-FOR-COM", "REMOTE-SHIPPING", "REDELIVERY-FEE", "HANDLING-FEE", "STORAGE-FEE", "WGS001", "E-PMNT")

    @shipping_details = @shipping_details.eager_load(:line_items, order: [:customer]).joins(:order).where(carrier_id: element.dataset[:carrier_id], status: "ready_for_pickup", orders: { store: current_store })

    assigns = {      
      shipping_details: @shipping_details
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#ready_for_pickup_1", html: render(partial: "carrier_list", assigns: assigns))
      .push_state()
      .broadcast
  end

  def build_shipping_detail
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @order = Order.find_by(id: element.dataset[:order_id])
    @order.shipping_details.create(eta_from: @order.eta_data_from, eta_to: @order.eta_data_to)

    if @order.status == 'in_progress'
      @order.shipping_details.each do |detail|
        if detail.status == 'not_ready' && detail.line_items.length > 0 && detail.line_items.all? {|item| item.status == 'ready'}
          detail.update(status: :staging)
        end
      end
    end
  end

  def build_pallet_shipping
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @shipping_detail = ShippingDetail.find_by(id: element.dataset[:shipping_detail_id])
    @shipping_detail.pallet_shippings.create(order_id: @shipping_detail.order_id, pallet_type: :pallet)
    @shipping_detail.pallet_shippings.where(pallet_type: :loose_box).destroy_all
  end

  def build_loose_box_shipping
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @shipping_detail = ShippingDetail.find_by(id: element.dataset[:shipping_detail_id])
    @shipping_detail.pallet_shippings.create(order_id: @shipping_detail.order_id, pallet_type: :loose_box)
  end

  def delete_shipping_detail
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    shipping_detail = ShippingDetail.find_by(id: element.dataset[:id])
    if shipping_detail.present? && params[:name].present?
      @order = Order.find_by(name: params[:name])
      if @order.shipping_details.first.status == 'shipped'
        flash[:notice] = 'Ship 1 has been shipped'
      else
        shipping_detail.line_items.update_all(shipping_detail_id: @order.shipping_details.first.id)
        shipping_detail.destroy 
        flash[:notice] = 'Shipping deleted successfully'
      end
    end
  end

  def delete_shipping_pallet
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    pallet = PalletShipping.find_by(id: element.dataset[:id])
    if pallet.present?
      if pallet.line_items.any?
        flash[:warning] = "An item is still assigned to this pallet"
      else
        pallet.destroy
        flash[:notice] = 'Pallet deleted successfully'
      end
    end
  end

  def update_unfulfillable_date
    @days_limit = element[:value]
  end

  def update_report_start_date
    @report_start_date = element[:value].to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = element.dataset[:end_date].to_datetime.at_end_of_day() + 8.hours
    @report_label = "Custom Range"
  end

  def update_report_end_date
    @report_start_date = element.dataset[:start_date].to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = element[:value].to_datetime.at_end_of_day() + 8.hours
    @report_label = "Custom Range"
  end

  def update_report_today
    @report_start_date = Date.today.to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = Date.today.to_datetime.at_end_of_day() + 8.hours
    @report_label = "Today"
  end

  def update_report_7_days
    @report_start_date = (Date.today - 7.days).to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = Date.today.to_datetime.at_end_of_day() + 8.hours
    @report_label = "Past 7 Days"
  end

  def update_report_30_days
    @report_start_date = (Date.today - 30.days).to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = Date.today.to_datetime.at_end_of_day() + 8.hours
    @report_label = "Past 30 Days"
  end

  def update_report_90_days
    @report_start_date = (Date.today - 90.days).to_datetime.at_beginning_of_day() + 8.hours
    @report_end_date = Date.today.to_datetime.at_end_of_day() + 8.hours
    @report_label = "Past 90 Days"
  end

  def update_report_year_to_date
    @report_start_date = (Date.today.beginning_of_year).to_datetime.at_beginning_of_day() + 8.hours
    @report_end_Date = Date.today.to_datetime.at_end_of_day() + 8.hours
    @report_label = "Year To Date"
  end

  def add_link_order
    current_order = Order.find_by(id: element.dataset[:current_order])
    new_order = Order.find_by(id: element.dataset[:new_order])
    order_list = []
    order_list.push(current_order.id)
    order_list.push(current_order.order_link)
    order_list.push(new_order.id)
    order_list.push(new_order.order_link)
    order_list = order_list.flatten.compact.uniq

    order_list.each do |o|
      Order.find_by(id: o).update(order_link: order_list)
    end
  end

  def remove_link_order
    link_order = Order.find_by(id: element.dataset[:link_id])
    order_list = link_order.order_link
    order_list.delete(link_order.id)
    link_order.update(order_link: nil)
    order_list.each do |o|
      Order.find_by(id: o).update(order_link: order_list)
    end
  end

  def create_cost
    ShippingDetail.find_by(id: element.dataset[:ship_id]).shipping_costs.create({ cost_type: element.dataset[:cost_type] })
  end

  def delete_cost
    ShippingCost.find_by(id: element.dataset[:cost_id]).destroy
  end

  def create_quote
    ShippingDetail.find_by(id: element.dataset[:ship_id]).shipping_quotes.create()
  end

  def delete_quote
    ShippingQuote.find_by(id: element.dataset[:quote_id]).destroy
  end

  def select_white_glove_address
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    shipping_detail = ShippingDetail.find_by(id: element.dataset[:shipping_detail_id])
    shipping_detail.update(white_glove_address_id: element.dataset[:directory_id])
  end

  def update_ship_ids
    @ship_ids = element.dataset[:ship_ids]
  end

  def merge_select_white_glove_address
    @white_glove_address = WhiteGloveAddress.find_by(id: element.dataset[:directory_id])
    @ship_ids = element.dataset[:ship_ids]
  end

  def filter_state
    if element.checked
      @state_filter = (element.dataset[:state_filter].split(",") + element.dataset[:state].split(",")).join(",")
    else
      @state_filter = (element.dataset[:state_filter].split(",") - element.dataset[:state].split(",")).join(",")
      unless @state_filter.present?
        @state_filter = ","
      end
    end
    current_store = element.dataset[:store]
  end

  def search_order_assign
    @query = element[:value].strip
    @line_items = LineItem.joins(:order).where(order_from: nil, status: :not_started, variant_id: element.dataset[:variant_id], orders: { store: current_store })
    @line_items = @line_items.where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee")
    
    @line_items = @line_items.joins(:order).where("cast(line_items.quantity as int) <= ? AND orders.name ILIKE ?", ProductVariant.find_by(id: element.dataset[:variant_id]).inventory_quantity.to_i, "%#{@query}%") if @query.present?

    @product_variant = ProductVariant.find_by(id: element.dataset[:variant_id])

    assigns = {
      order_by: @order_by,
      direction: @direction,
      line_items: @line_items,
      product_variant: @product_variant
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#assign-search-results", html: render(partial: "search_assign", assigns: assigns))
      .push_state()
      .broadcast
  end

  def assign_to_order
    product_variant = ProductVariant.find_by(id: element.dataset[:product_variant_id])
    line_item = LineItem.find_by(id: element.dataset[:line_item_id])

    if product_variant.present? && line_item.present?
      product_variant.update(old_inventory_quantity: product_variant.inventory_quantity.to_i, inventory_quantity: product_variant.inventory_quantity.to_i - line_item.quantity.to_i, to_do_quantity: product_variant.to_do_quantity.to_i + line_item.quantity.to_i)

      line_item.update(status: :ready)

      InventoryHistory.create(product_variant_id: product_variant.id, user_id: element.dataset[:user_id], event: "Assigned to #{line_item.order.name}", adjustment: -line_item.quantity.to_i, quantity: product_variant.inventory_quantity)
    end
  end

  def update_overstock_quantity
    ret = ReturnProduct.find_by(id: element.dataset[:ret_id])
    ret.update(quantity: element.value)
  end

  def update_overstock_price
    product_variant = ProductVariant.find_by(id: element.dataset[:product_variant_id])
    product_variant.update(price: element.value)
  end

  def update_shipping_method
    current_store = element.dataset[:current_store]
    amount = element.dataset[:amount].to_f
    shipping_line = ShippingLine.find_by(id: element.dataset[:shipping_line_id])

    if element.value == "admin-shipping-method-free"
      shipping_line.update(title: "Admin Shipping Method - Free", price: 0)
      
    elsif element.value == "standard-curbside-delivery"
      shipping_amount = StandardShippingRate.where(store: current_store, shipping_method: "Curbside Delivery").where("order_min_price <= ? AND order_max_price >= ?", amount, amount)&.first&.discount.to_s
      shipping_line.update(title: "Standard - Curbside Delivery", price: shipping_amount)

    elsif element.value == "standard-white-glove-delivery"
      shipping_amount = StandardShippingRate.where(store: current_store, shipping_method: "White Glove Delivery").where("order_min_price <= ? AND order_max_price >= ?", amount, amount)&.first&.discount.to_s
      shipping_line.update(title: "Standard - White Glove Delivery", price: shipping_amount)

    elsif element.value == "standard-local-pickup"
      shipping_line.update(title: "Standard - Local Pickup", price: 0)
    end

    shipping_line.update(editable: true)
  end

  protected

  def prepare_variables
    params[:query] = params[:order_type] if params[:query].blank? && params[:order_type].present?
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    if params[:order_type].present?
      orders = Order.eager_load(:customer,:shipping_details,:shipping_line).where(store: 'us',order_type: params[:order_type].to_s).where.not(status: ['cancel_confirmed','completed']).order(@order_by => @direction).order(:name => @direction)
    else
      orders = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).set_store('us').order(@order_by => @direction).order(:name => @direction)
      orders = orders.joins(:customer, :billing_address, :customer, :line_items).where("(orders.name ILIKE ?) or (orders.shopify_order_id ILIKE ?) or (customers.first_name ILIKE ?) or (customers.last_name ILIKE ?) or (billing_addresses.phone ILIKE ?) or (customers.email ILIKE ?) or (line_items.sku ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    end
    page_count = (orders.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @orders = pagy(orders, page: @page)
  end


  private

  def order_params
    params.require(:order).permit(:id, :user_id, :status, :shopify_order_id, :hold_until_date, :contact_email, :currency,
    :cancel_reason, :hold_reason, :current_subtotal_price, :financial_status, :fulfillment_status, :order_notes, :created_at, :updated_at, :current_total_discounts, :current_total_tax, :order_id, :name, :customer_id, shipping_details_attributes: [:white_glove_directory_id, :white_glove_address_id, :additional_charges, :additional_fees, :upgrade, :actual_invoiced, :white_glove_fee, :local_white_glove_delivery, :local_pickup, :remote, :overhang, :tracking_number, :printed_bol, :printed_packing_slip, :local_delivery, :status, :estimated_shipping_cost, :date_booked, :hold_until_date, :white_glove_delivery, :pickup_start_date, :shipping_notes, :carrier_id, :_destroy, :id, pallet_shippings_attributes: [:length, :height, :depth, :width, :weight, :_destroy, :id, :pallet_id, :order_id, :auto_calc], shipping_costs_attributes: [:id, :cost_type, :name, :amount], shipping_quotes_attributes: [:id, :truck_broker_id, :carrier_id, :amount, :selected]], line_items_attributes: [:id, :order_id, :order_from, :shipping_detail_id, :status, :purchase_quantity, :pallet_shipping_id], discount_codes: [])
  end

  def ship_params
    params.require(:order).permit(:id, :shipping_detail_id)
  end

  def update_shipped_order
    shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer, :shipping_details]).joins(:line_items,:order).where("(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)","%#{"warranty"}%","WGS001","HLD001","HFE001",current_store,nil)
    shipping_details = shipping_details.where(status: 'shipped')
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])

    page_count = (shipping_details.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @shipping_details = pagy(shipping_details, page: @page)

    assigns = {
      page: @page,
      pagy: @pagy,
      shipping_details: @shipping_details
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#shipped-results", html: render(partial: "shipped_order_results", assigns: assigns, ship_params: 'shipped'))
      .push_state()
      .broadcast
  end

  def update_emca_client
    params[:query] = params[:order_type] if params[:query].blank? && params[:order_type].present?
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    if params[:order_type].present?
      orders = Order.eager_load(:customer,:shipping_details,:shipping_line).where(store: 'canada',order_type: params[:order_type].to_s).where.not(status: ['cancel_confirmed','completed']).order(@order_by => @direction).order(:name => @direction)
    else
      orders = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).set_store('canada').order(@order_by => @direction).order(:name => @direction)
      orders = orders.joins(:customer,:line_items).where("(orders.name ILIKE ?) or (orders.shopify_order_id ILIKE ?) or (customers.first_name ILIKE ?) or (customers.last_name ILIKE ?) or (customers.phone ILIKE ?) or (customers.email ILIKE ?) or (line_items.sku ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%") if @query.present?
    end

    page_count = (orders.count / Pagy::VARS[:items].to_f).ceil
    
    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @orders = pagy(orders, page: @page)
    if params[:order_type].present?
      assigns = {
        query: @query,
        order_by: @order_by,
        direction: @direction,
        page: @page,
        pagy: @pagy,
        orders: @orders,
        order_type: params[:order_type].to_s
      }
    else
      assigns = {
        query: @query,
        order_by: @order_by,
        direction: @direction,
        page: @page,
        pagy: @pagy,
        orders: @orders.uniq
      }
    end
    uri = URI.parse([request.base_url, request.path].join)
    if params[:order_type].present?
      uri.query = (params.permit!.slice("order_type").to_query + "&").concat(assigns.except(:orders, :pagy).to_query)
      morph :nothing
      cable_ready
        .inner_html(selector: "#emca-order-type-results", html: render(partial: "emca_order_type_results", assigns: assigns))
        .push_state(url: uri.to_s)
        .broadcast
    else
      uri.query = assigns.except(:orders, :pagy).to_query
      morph :nothing
      cable_ready
        .inner_html(selector: "#emca-order-search-results", html: render(partial: "emca_search_results", assigns: assigns))
        .push_state(url: uri.to_s)
        .broadcast
    end
  end

  def update_client
    prepare_variables
    if params[:order_type].present?
      assigns = {
        query: @query,
        order_by: :eta,
        direction: "asc",
        page: @page,
        pagy: @pagy,
        orders: @orders,
        order_type: params[:order_type].to_s
      }
    else
      assigns = {
        query: @query,
        order_by: @order_by,
        direction: @direction,
        page: @page,
        pagy: @pagy,
        orders: @orders.uniq
      }
    end
    uri = URI.parse([request.base_url, request.path].join)
    if params[:order_type].present?
      uri.query = (params.permit!.slice("order_type").to_query + "&").concat(assigns.except(:orders, :pagy).to_query)
      morph :nothing
      cable_ready
        .inner_html(selector: "#order-type-results", html: render(partial: "order_type_results", assigns: assigns))
        .push_state(url: uri.to_s)
        .broadcast
    else
      uri.query = assigns.except(:orders, :pagy).to_query
      morph :nothing
      cable_ready
        .inner_html(selector: "#order-search-results", html: render(partial: "search_results", assigns: assigns))
        .push_state(url: uri.to_s)
        .broadcast
    end
  end

  def update_order
    @query = params[:query]
    orders = Order.where(store: current_store)
    orders = orders.joins(:customer,:line_items).where("(orders.name ILIKE ?) or (orders.shopify_order_id ILIKE ?) or (orders.order_type ILIKE ?) or (customers.first_name ILIKE ?) or (customers.last_name ILIKE ?) or (line_items.sku ILIKE ?)","%#{@query}%","%#{@query}%","%#{@query}%","%#{@query}%","%#{@query}%","%#{@query}%").first(10) if @query.present?
    
    @orders = orders

    assigns = {
      query: @query,
      orders: @orders.uniq
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#order-search-edit-results", html: render(partial: "admin/orders/search_edit", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_link_order
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])

    orders = Order.set_store(current_store).order(@order_by => @direction)
    orders = orders.joins(:customer).where("(orders.name ILIKE ?) or (customers.email ILIKE ?) or (customers.first_name ILIKE ?) or (customers.last_name ILIKE ?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%").first(10) if @query.present?
    
    @orders = orders

    assigns = {
      query: @query,
      orders: @orders.uniq,
      current_order: @current_order
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing
    
    cable_ready
      .inner_html(selector: "#order-search-link-order-results", html: render(partial: "search_link_order", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_warehouse_stock
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    current_store = element.dataset[:store_type]
    if params[:warehouse_name].present?
      @warehouse_variants = WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).find_by_name(params[:warehouse_name]).id)
    else
      @warehouse_variants = WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).first.id)
    end
    page_count = (@warehouse_variants.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @warehouse_variants = pagy(@warehouse_variants, page: @page)

    assigns = {
      query: @query,
      order_by: @order_by,
      direction: @direction,
      page: @page,
      pagy: @pagy,
      warehouse_variants: @warehouse_variants,
      current_user: @current_user
    }

    uri = URI.parse([request.base_url, request.path].join)
    uri.query = assigns.except(:line_items, :pagy).to_query

    morph :nothing    
    cable_ready
    .inner_html(selector: "#warehouse_stock_result", html: render(partial: "warehouse_stock_result", assigns: assigns))
    .push_state(url: uri.to_s)
    .broadcast

  end

  def update_stock
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.where("(product_variants.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "us", "%#{"warranty"}%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%")
    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%") if @query.present?

    assigns = {
      query: @query,
      line_items: @line_items,
      current_user: @current_user
    }

    morph :nothing
    
    cable_ready
      .inner_html(selector: "#product-variant-header-results", html: render(partial: "admin/orders/product_variant_header_results", assigns: assigns))
      .push_state()
      .broadcast    
  end

  def update_emca_stock
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.where("(product_variants.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "canada", "%#{"warranty"}%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%")
    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%") if @query.present?

    assigns = {
      query: @query,
      line_items: @line_items, 
      current_user: @current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#product-variant-header-results", html: render(partial: "admin/orders/product_variant_header_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_main_stock
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
      "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) > 2)", "us", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
    ).order(created_at: :desc)

    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%").order(inventory_quantity: :desc) if @query.present?

    assigns = {
      query: @query,
      line_items: @line_items,
      current_user: @current_user
    }

    morph :nothing
    
    cable_ready
      .inner_html(selector: "#stock_result", html: render(partial: "admin/orders/stock_result", assigns: assigns))
      .push_state()
      .broadcast    
  end

  def update_emca_main_stock
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
      "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) > 2)", "canada", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
    ).order(created_at: :desc)

    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%").order(inventory_quantity: :desc) if @query.present?

    assigns = {
      query: @query,
      line_items: @line_items, 
      current_user: @current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#emca_stock_result", html: render(partial: "admin/orders/emca_stock_result", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_main_swatch
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
      "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) < 3)", "us", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
    ).order(created_at: :desc)

    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%").order(inventory_quantity: :desc) if @query.present?
    
    page_count = (@line_items.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @line_items = pagy(@line_items, page: @page)


    assigns = {
      query: @query,
      page: @page,
      pagy: @pagy,
      line_items: @line_items,
      current_user: @current_user
    }

    morph :nothing
    
    cable_ready
      .inner_html(selector: "#swatch_result", html: render(partial: "admin/orders/swatch_result", assigns: assigns))
      .push_state()
      .broadcast    
  end

  def update_emca_main_swatch
    @current_user = User.find(element.dataset[:user_id])
    @query = params[:query]
    @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
      "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) < 3)", "canada", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
    ).order(created_at: :desc)

    @line_items = @line_items.where("(product_variants.sku ILIKE ?) or (product_variants.title ILIKE ?)","%#{@query}%","%#{@query}%").order(inventory_quantity: :desc) if @query.present?
    
    page_count = (@line_items.count / Pagy::VARS[:items].to_f).ceil

    @page = (params[:page] || 1).to_i
    @page = page_count if @page > page_count
    @page = 1 if @page < 1
    @pagy, @line_items = pagy(@line_items, page: @page)

    assigns = {
      query: @query,
      page: @page,
      pagy: @pagy,
      line_items: @line_items, 
      current_user: @current_user
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#emca_swatch_result", html: render(partial: "admin/orders/emca_swatch_result", assigns: assigns))
      .push_state()
      .broadcast
  end

  def permitted_column_name(column_name)
    %w[name created_at].find { |permitted| column_name == permitted } || "created_at"
  end

  def permitted_direction(direction)
    %w[asc desc].find { |permitted| direction == permitted } || "desc"
  end
end