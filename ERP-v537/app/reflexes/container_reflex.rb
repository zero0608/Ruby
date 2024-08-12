# frozen_string_literal: true

class ContainerReflex < ApplicationReflex

  def search
    params[:query] = element[:value].strip
    update_order
  end

  def emus_search
    params[:query] = element[:value].strip
    update_containers
  end

  def emca_search
    params[:query] = element[:value].strip
    update_emca_containers
  end

  def arriving_search
    params[:query] = element[:value].strip
    update_arriving_containers
  end

  def post
    charge = ContainerCharge.find(element.dataset[:id])
    charge.update(posted: element.checked)
  end

  def charges_update
    @container = Container.find(element.dataset[:container_id])
    @container.update(container_params)
    if @container.purchase_items.pluck(:item_cbm).reject(&:blank?).map(&:to_f).sum.present?
      @container.count_container_cost
    end
  end

  def update
    @container = Container.find(element.dataset[:container_id])
    @container.update(container_params)
    
    if container_params[:status].present? && container_params[:status] == 'arrived'
      @container.purchase_items.each do |item|
        item.line_item.update(status: :ready) if item.line_item.present?
      end
    end

    @container.purchase_items.each do |item|
      variant = item.product_variant if (item.product_variant_id.present?) 
      begin
        Magento::UpdateOrder.new(variant.store).update_arriving_case_1_3(variant) if !(variant.nil?)
      rescue => e
        puts "\n\n\n\n\n #{e.message}"
      end
      if item.line_item_id.present?
        @order = item.line_item.order
        begin
          Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
        rescue => e
          puts "\n\n\n\n\n #{e.message}"
        end
      end
    end
    # if element.dataset[:arriving_to_dc].present?
    #   @container.purchase_items.each do |item|
    #     @a = 0
    #     variant = item.product_variant if (item.product_id.present?) && (item.product_variant_id.present?)
    #     variant = item.line_item.product_variant if item.line_item.present?
    #     if !(variant.nil?) && (variant.try(:inventory_quantity).to_i == 0)
    #       variant.try(:purchase_items).each do |cant_item|
    #         if cant_item.containers.present?
    #           cant_item.containers.each do |cant|
    #             @a = @a + cant_item.try(:quantity).to_i if cant.arriving_to_dc.present? && !(cant.status == "arrived")
    #           end
    #         end
    #       end
    #       if (@a > 0)
    #         @a = @a - (LineItem.joins(:order).where(sku: variant.sku, orders: { store: current_store }).where("orders.created_at >= ?", item.purchase.created_at).where.not(orders: { order_type: 'Unfulfillable' }).pluck(:quantity).reject(&:blank?).map(&:to_i).sum)
    #         Magento::UpdateOrder.new.update_arriving_date(variant,@container,@a)
    #         Magento::UpdateOrder.new.update_arriving_quantity(variant)
    #       end
    #     end
    #   end
    # end
    if LineItem.where(container_id: @container.id).present?
      LineItem.where(container_id: @container.id).each do |item|
        @order = item.order
        begin
          Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
        rescue => e
          puts "\n\n\n\n\n #{e.message}"
        end
      end
    end
    if @container.purchase_items.pluck(:item_cbm).reject(&:blank?).map(&:to_f).sum.present?
      @container.count_container_cost
    end
  end

  def en_route
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @container = Container.find_by(id: element.dataset[:container_id])
    
    @container.purchase_items.each do |purchase_item|
      product_variant = purchase_item.product_variant if purchase_item.product_variant_id.present?
      if purchase_item.line_item_id.nil? && purchase_item.quantity.to_i != 0 && product_variant.present? && product_variant.line_items.joins(:order).where(status: "not_started", orders: { store: current_store }).where.not(orders: { status: ["cancel_request", "cancel_confirmed"] }).present? && product_variant&.inventory_quantity.to_i == 0
        product_variant.line_items.joins(:order).where(status: "not_started", orders: { store: current_store }).where.not(orders: { status: ["cancel_request", "cancel_confirmed"] }).each do |line_item|
          if purchase_item.quantity.to_i > 0 && purchase_item.quantity.to_i > line_item.quantity.to_i && purchase_item.line_item_id.nil?
            purchase_item.update(quantity: purchase_item.quantity.to_i - line_item.quantity.to_i)
            line_item.update(status: "en_route", container_id: @container.id)
          end
        end
        if purchase_item.quantity.to_i > 0
          Magento::UpdateOrder.new(product_variant.store).update_arriving_date(product_variant, @container, purchase_item.quantity.to_i)
          Magento::UpdateOrder.new(product_variant.store).update_arriving_quantity(product_variant)
        else
          Magento::UpdateOrder.new(product_variant.store).update_arriving_case_1_3(product_variant)
          Magento::UpdateOrder.new(product_variant.store).update_arriving_quantity(product_variant)
        end
      end
    end

    @container.line_items.update_all(status: "en_route")

    @container.purchase_items.each do |pi|
      pi.line_item&.update(status: "en_route")
    end

    @container.update(status: "en_route")
    Magento::UpdateOrder.new(current_store).update_container(@container)


    UserNotification.with(order: "nil", issue: "nil", user: User.where(deactivate: [false, nil]).find_by(id: element.dataset[:user_id].to_i), content: "arriving", container: @container).deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'arriving_container' = ?", "1"))
  end

  def sync_data
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @container = Container.find_by(id: element.dataset[:container_id])
    Magento::UpdateOrder.new(current_store).update_container(@container)
  end

  def supplier_filter
    if params[:container][:supplier_id].present?
      purchase_items = PurchaseItem.joins(:purchase).where(status: :container_ready, purchases: { supplier_id: params[:container][:supplier_id] })
      purchase_items = purchase_items.joins(:purchase).where(purchases: { store: current_store })
    end
    @purchase_items = purchase_items
  
    assigns = {      
      purchase_items: @purchase_items
    }
  
    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query
  
    morph :nothing
  
    cable_ready
      .inner_html(selector: "#supplier_filter", html: render(partial: "supplier_filter", assigns: assigns))
      .push_state()
      .broadcast
  end

  def create_cost
    Container.find_by(id: element.dataset[:container_id]).container_charges.create
  end

  def delete_cost
    ContainerCharge.find_by(id: element.dataset[:charge_id]).destroy
    # ContainerCost.find_by(id: element.dataset[:cost_id]).destroy
  end

  def update_arriving
    if element.dataset[:status] == "this_week"
      @arriving_label = "This Week"
      @arriving_date_begin = Time.now.at_beginning_of_week
      @arriving_date_end = Time.now.at_end_of_week
    elsif element.dataset[:status] == "next_week"
      @arriving_label = "Next Week"
      @arriving_date_begin = Time.now.next_day(7).at_beginning_of_week
      @arriving_date_end = Time.now.next_day(7).at_end_of_week
    elsif element.dataset[:status] == "this_month"
      @arriving_label = "This Month"
      @arriving_date_begin = Time.now.at_beginning_of_month
      @arriving_date_end = Time.now.at_end_of_month
    end
    session[:store] = element.dataset[:store]
  end

  def warehouse_update
    @container = Container.find(element.dataset[:container_id])
    @container.update(container_params)
  end

  private

  def container_params
    params.require(:container).permit(:warehouse_id, :ocean_carrier_id, :supplier_id, :container_number, :shipping_date, :port_eta, :arriving_to_dc, :status, :ocean_carrier, :freight_carrier, :carrier_serial_number, :container_comment, :received_date, container_purchases_attributes: [:container_id, :purchase_item_id, :id], container_costs_attributes: [:id, :container_id, :name, :amount], container_charges_attributes: [:id, :container_id, :charge, :quote, :invoice_number, :invoice_amount, :tax_amount, :invoice_difference, :posted, files: [:id, :filename]])
  end

  def update_order
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])

    orders = Order.set_store(current_store).order(@order_by => @direction)
    orders = orders.joins(:customer).where("(name ILIKE ?) or (shopify_order_id ILIKE ?) or (order_type ILIKE ?) or (customers.first_name ILIKE ?) or (customers.last_name ILIKE ?)","%#{@query}%","%#{@query}%","%#{@query}%","%#{@query}%","%#{@query}%") if @query.present?
    
    @orders = orders

    assigns = {
      query: @query,
      
      orders: @orders
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#assign-search-result", html: render(partial: "assign_search", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_containers
    @query = params[:query]
    @containers = Container.where(store: "us").where("(containers.container_number = ?) or (containers.carrier_serial_number ILIKE ?)", @query.upcase.gsub("CTUS", "").to_i, "%#{@query}%") if @query.present?

    assigns = {
      containers: @containers
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#container-header-results", html: render(partial: "container_search_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_emca_containers
    @query = params[:query]
    @containers = Container.where(store: "canada").where("(containers.container_number = ?) or (containers.carrier_serial_number ILIKE ?)", @query.upcase.gsub("CTCA", "").to_i, "%#{@query}%") if @query.present?

    assigns = {
      containers: @containers
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#container-header-results", html: render(partial: "container_search_results", assigns: assigns))
      .push_state()
      .broadcast
  end

  def update_arriving_containers
    @query = params[:query]
    @order_by = permitted_column_name(params[:order_by])
    @direction = permitted_direction(params[:direction])
    containers = Container.where(store: current_store).where.not(status: :arrived).order(:arriving_to_dc)
    containers = containers.where(container_number: "#{@query}".to_i) if @query.present?
    
    @containers = containers

    assigns = {
      containers: @containers
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing

    cable_ready
      .inner_html(selector: "#container-arriving-results", html: render(partial: "arriving_results", assigns: assigns))
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
