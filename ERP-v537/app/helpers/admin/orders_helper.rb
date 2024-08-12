# frozen_string_literal: true

module Admin::OrdersHelper

  def order_status_update order
    ::Audited.store[:current_user] = User.find_by(email: 'admin@eternity-erp.com')
    if order.status == 'new_order'
      order.shipping_details.each do |detail|
        if detail.line_items.length > 0 && detail.line_items.all? {|item| item.status == 'ready'}
          detail.update(status: :staging)
        else
          detail.update(status: :not_ready)
        end
      end
    elsif !(order.status == 'cancel_request' || order.status == 'cancel_confirmed' || order.status == 'hold_request' || order.status == 'hold_confirmed')
      order.shipping_details.each do |detail|
        if detail.status == 'not_ready' && detail.line_items.length > 0 && detail.line_items.reject { |item| (item.title&.include? 'Swatch' or item.sku.nil? or item.sku.length < 3) or (item.try(:sku)&.include? 'warranty') or (item.try(:sku) == 'WGS001') or (item.try(:sku) == 'HLD001') or (item.try(:sku) == 'HFE001') }.all? {|item| item.status == 'ready' }
          detail.update(status: :staging)
        end
      end
    end
    
    if (order.shipping_details.all? { |ship| ship.status == 'shipped'})
      order.update(status: 'completed')
    # elsif (order.line_items.all? { |item| item.status == 'ready'})
    #   order.update(order_type: 'Fulfillable')
    elsif !(['cancel_confirmed', 'delayed', 'hold_confirmed', 'cancel_request', 'rejected', 'hold_request', 'pending_payment', 'completed'].include? order.status)
      order.update(status: 'in_progress')
    end
  end

  def update_order_type(order)
    if !(order.line_items.all? { |item| item.title.present? && (item.title&.include? 'Swatch' or item.sku.nil? or item.sku.length < 3) }) && order.shipping_details.all? { |detail| !(detail.status == 'not_ready' || detail.status == 'cancelled' || detail.status == 'unbooked' || detail.status == 'hold') }
      order.update(order_type: 'Fulfillable')
    end
  end

  def send_status_to_m2_qs
    orders = Order.where("created_at::date = ?", Date.today - 24.hours)
    orders = orders.where(order_type: 'Fulfillable', sent_mail: nil)
    if orders.present?
      orders.each do |order|
        status = "Processing:Preparing"
        order.update(sent_mail: 0)
        Magento::UpdateOrder.new(order.store).update_status_for_M2(order.shopify_order_id, status)
      end
    end
  end

  def send_status_to_m2_mto
    orders = Order.where("created_at::date = ?", Date.today - 6.days)
    orders = orders.where(order_type: 'Unfulfillable', sent_mail: nil)
    if orders.present?
      orders.each do |order|
        if order.shipping_details.all? {|item| item.status == 'not_ready'}
          status = "Processing:In Production"
          order.update(sent_mail: 1)
          Magento::UpdateOrder.new(order.store).update_status_for_M2(order.shopify_order_id, status)
        end
      end
    end
    en_orders = Order.where(order_type: 'Unfulfillable')
  end

  def get_shipping ship
    @a = []
    if ship.order.shipping_details.count >= 1
      ship.order.shipping_details.each do |sh|
        @a.push sh.id
      end
      "#{@a.find_index(ship.id) + 1}" + "/" + "#{ship.order.shipping_details.count}"      
    else
      'Ship'
    end
  end

  def type_order(order)
    ::Audited.store[:current_user] = current_user
    @type = []
    order.line_items.each do |item|
      @type.push type_item(item)
    end
    if @type.uniq.reject(&:blank?)&.include? 'Unfulfillable'
      order.update(order_type: 'Unfulfillable')
    else
      order.update(order_type: @type.uniq.reject(&:blank?).first)
    end
  end

  def type_item(item)
    if !(item.ready?)
      'Unfulfillable'
    else
      if item.title&.include? 'Mulberry'
        nil
      elsif item.title&.include? 'Swatch'
        item.update(status: 'ready')
        'SW'
      elsif (item.variant_id.present?) && !(item.title&.include? 'Mulberry')
        variant = ProductVariant.find_by(sku: item.sku)
        if item.quantity.to_i > variant.try(:inventory_quantity).to_i
          'Unfulfillable'
        else
          item.update(status: 'ready')
          'Fulfillable'
        end
      end
    end
  end

  def get_changes(key,value)
    if value != nil && key == "status"
      Order.statuses.key(value)      
    end
  end 

  def mul(first, second)
    first.to_f * second.to_f
  end

  def store st
    if st == 'us'
      'eternitymodern.com'
    else
      'eternitymodern.ca'
    end
  end

  def update_shipping_status(ship_details)
    if ship_details.present?
      ship_details.each do |sh|
        if (sh.line_items.pluck(:status)&.include? 'not_started')
          sh.update(status: 'not_ready')
        end 
      end
    end
  end
end
