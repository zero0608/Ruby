class Admin::InvoicesController < ApplicationController
  def new    
    @customer = Customer.find_by(id: params[:customer_id])
    
    invoice_number = nil
    order_name = nil

    if current_showroom["store"] == "us"
      i = 8800000
      while Invoice.find_by(invoice_number: current_showroom["abbreviation"].to_s.upcase + "-EMUS" + i.to_s).present? || Order.find_by(name: "S-EMUS" + i.to_s).present? do
        i += 1
      end
      invoice_number = current_showroom["abbreviation"].to_s.upcase + "-EMUS" + i.to_s
      order_name = "S-EMUS" + i.to_s
    else
      i = 8600000
      while Invoice.find_by(invoice_number: current_showroom["abbreviation"].to_s.upcase + "-EMCA" + i.to_s).present? || Order.find_by(name: "S-EMCA" + i.to_s).present? do
        i += 1
      end
      invoice_number = current_showroom["abbreviation"].to_s.upcase + "-EMCA" + i.to_s
      order_name = "S-EMCA" + i.to_s
    end
    
    @invoice = @customer.invoices.create(invoice_number: invoice_number.to_s, order_name: order_name.to_s, status: 0, employee_id: current_user.employee.id, store: current_showroom["store"])

    redirect_to edit_admin_invoice_path(@invoice)
  end

  def edit
    @invoice = Invoice.find_by(id: params[:id])
    render :layout => "sales"
  end

  def update
    @invoice = Invoice.find_by(id: params[:id])
    if @invoice.update(invoice_params)
      redirect_to edit_admin_invoice_path(@invoice)
    else
      render 'edit'
    end
  end

  def pdf
    @invoice = Invoice.find_by(id: params[:id])
    if params[:type] == "quote_offered" && @invoice.status == "new_lead"
      @invoice.update(status: :quote_offered)
    end
  end

  def no_sale
    @invoice = Invoice.find_by(id: invoice_params[:id])
    @invoice.update(invoice_params)
    @invoice.update(status: :no_sale)
    redirect_to edit_admin_invoice_path(@invoice)
  end

  def create_order
    @invoice = Invoice.find_by(id: params[:invoice_id])
    status = ""
    if @invoice.payment_method ==  "Credit Card" || @invoice.payment_method == "Cash" || @invoice.payment_method == "Trade Cheque"
      @invoice.update(status: :full_payment)
      status = "new_order"
    else
      @invoice.update(status: :deposit)
      status = "pending_payment"
    end
    
    order_store = current_showroom["store"]

    subtotal = (@invoice.invoice_line_items.sum { |item| item.price.present? ? (item.quantity * item.price) : (item.quantity * (item.product_variant&.m2_product_id.present? ? item.product_variant&.special_price.to_f : item.product_variant&.price.to_f)) }).to_f
    discount_code = @invoice.discount
    discount_amount = subtotal * @invoice.discount_amount.to_f * 0.01

    shipping_amount = 0
    if @invoice.shipping_type == "Standard"
      shipping_amount = StandardShippingRate.where("shipping_method ILIKE ?", "%#{@invoice.shipping_method}%").where("order_min_price <= ? AND order_max_price >= ?", subtotal + discount_amount, subtotal + discount_amount)&.first&.discount.to_f
    elsif @invoice.shipping_type == "Local"
      if @invoice.shipping_method == "Curbside Delivery - Waive Fee"
        shipping_amount = 0
      else
        shipping_amount = LocalShippingRate.where("shipping_method ILIKE ?", "%#{@invoice.shipping_method}%").where("order_min_price <= ? AND order_max_price >= ?", subtotal + discount_amount, subtotal + discount_amount)&.first&.discount.to_f
      end
    elsif @invoice.shipping_type == "Remote"
      shipping_amount = RemoteShippingRate.where("shipping_method ILIKE ?", "%#{@invoice.shipping_method}%").where("order_min_price <= ? AND order_max_price >= ?", subtotal + discount_amount, subtotal + discount_amount)&.first&.discount.to_f
    elsif @invoice.shipping_type == "Admin"
      shipping_amount = @invoice.shipping_amount.to_f
    end
    
    tax_amount = 0
    unless @invoice.waive_tax
      tax_amount = @invoice.tax_amount.present? ? (subtotal - discount_amount + shipping_amount) * @invoice&.tax_amount.to_f * 0.01 : 0
    end
    
    Order.create(name: @invoice.order_name, contact_email: @invoice.customer.email, store: order_store, payment_method: @invoice.payment_method, customer_id: @invoice.customer.id, employee_id: current_user.employee_id, discount_codes: JSON.parse('{"discount_description":"' + discount_code.to_s + '", "discount_amount":"-' + discount_amount.to_s + '"}'), tax_lines: JSON.parse('{"price":"' + tax_amount.to_s + '"}'), status: status, order_notes: @invoice.notes)

    @order = Order.find_by(name: @invoice.order_name)

    @invoice.update(order_id: @order.id, deposit_date: Date.today)

    ShippingLine.create(order_id: @order.id, title: @invoice.shipping_type.to_s + " - " + @invoice.shipping_method.to_s, price: shipping_amount)

    BillingAddress.create(order_id: @order.id, address1: @invoice.customer.customer_billing_address&.address, city: @invoice.customer.customer_billing_address&.city, address2: @invoice.customer.customer_billing_address&.state, country: @invoice.customer.customer_billing_address&.full_country, zip: @invoice.customer.customer_billing_address&.zip, first_name: @invoice.customer.customer_billing_address&.first_name.present? ? @invoice.customer.customer_billing_address&.first_name : @invoice.customer&.first_name, last_name: @invoice.customer.customer_billing_address&.last_name.present? ? @invoice.customer.customer_billing_address&.last_name : @invoice.customer&.last_name, name: @invoice.customer.customer_billing_address&.full_name, phone: @invoice.customer.customer_billing_address&.phone.present? ? @invoice.customer.customer_billing_address&.phone : @invoice.customer&.phone)

    ShippingAddress.create(order_id: @order.id, address1: @invoice.customer.customer_shipping_address&.address, city: @invoice.customer.customer_shipping_address&.city, address2: @invoice.customer.customer_shipping_address&.state, country: @invoice.customer.customer_shipping_address&.full_country, zip: @invoice.customer.customer_shipping_address&.zip, first_name: @invoice.customer.customer_shipping_address&.first_name.present? ? @invoice.customer.customer_shipping_address&.first_name : @invoice.customer&.first_name, last_name: @invoice.customer.customer_shipping_address&.last_name.present? ? @invoice.customer.customer_shipping_address&.last_name : @invoice.customer&.last_name, name: @invoice.customer.customer_shipping_address&.last_name.present? ? @invoice.customer.customer_shipping_address&.first_name + " " + @invoice.customer.customer_shipping_address&.last_name : @invoice.customer&.full_name, phone: @invoice.customer.customer_shipping_address&.phone.present? ? @invoice.customer.customer_shipping_address&.phone : @invoice.customer&.phone, email: @invoice.customer.customer_shipping_address&.email.present? ? @invoice.customer.customer_shipping_address&.email : @invoice.customer&.email)

    @shipping_detail = ShippingDetail.create(order_id: @order.id, status: "not_ready")
    @invoice.invoice_line_items.each do |item|
      variant = ProductVariant.find_by(id: item.product_variant_id)
      if item.price.present?
        unless item.return_id.present?
          LineItem.create(order_id: @order.id, product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: item.price.to_f, quantity: item.quantity.to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: variant&.title.to_s, name: variant&.title.to_s, shipping_detail_id: @shipping_detail.id, store: @order.store, status: "not_started", additional_notes: item.additional_notes)
        else
          ret = ReturnProduct.find_by(id: item.return_id)
          ret.update(quantity: ret.quantity - item.quantity.to_i)
          LineItem.create(order_id: @order.id, product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: item.price.to_f, quantity: item.quantity.to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: "WS-" + variant&.title.to_s, name: "WS-" + variant&.title.to_s, shipping_detail_id: @shipping_detail.id, store: @order.store, status: "ready", additional_notes: item.additional_notes)
        end
        
      else
        unless item.mto
          variant.update(old_inventory_quantity: variant&.inventory_quantity.to_i, inventory_quantity: variant&.inventory_quantity.to_i - item.quantity.to_i)
          InventoryHistory.create(product_variant_id: variant.id, event: "Order Created (#{@order.name})", adjustment: -item.quantity.to_i, quantity: variant.inventory_quantity)
        end
        
        if variant.inventory_quantity < 0 || item.mto
          LineItem.create(order_id: @order.id, product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: (variant&.m2_product_id.present? ? variant&.special_price.to_f : variant&.price.to_f), quantity: item.quantity.to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: variant&.title.to_s, name: variant&.title.to_s, shipping_detail_id: @shipping_detail.id, store: @order.store, status: "not_started", additional_notes: item.additional_notes)
          @order.update(order_type: "Unfulfillable")
        else
          LineItem.create(order_id: @order.id, product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: (variant&.m2_product_id.present? ? variant&.special_price.to_f : variant&.price.to_f), quantity: item.quantity.to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: variant&.title.to_s, name: variant&.title.to_s, shipping_detail_id: @shipping_detail.id, store: @order.store, status: "ready", additional_notes: item.additional_notes)
        end
      end
    end

    @order.update(order_type: "Fulfillable") if @order.order_type.nil?

    redirect_to edit_admin_order_path(@order)
  end

  def additional_payment
    @invoice = Invoice.find_by(id: params[:invoice_id])
    @invoice.update(invoice_params)
    @invoice.update(status: "full_payment", additional_deposit_date: Date.today)
    @invoice.order.update(status: "new_order")
    redirect_to edit_admin_order_path(@invoice.order)
  end

  def commission
    if current_user.user_group.hr_view
      @quarter ||= (Date.today.month - 1) / 3 + 1
      @year ||= Date.today.year

      if params[:employee_id].present?
        @employee = Employee.find_by(id: params[:employee_id])

        @o1 = Order.where(employee_id: @employee&.id).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 1, 1).beginning_of_month, Time.zone.local(@year, 3, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o1_sales = @o1.sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f } 

        @o1_commission = @employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", @o1_sales, @o1_sales)&.first&.rate.to_f * 0.01 * @o1_sales

        @o2 = Order.where(employee_id: @employee&.id).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 4, 1).beginning_of_month, Time.zone.local(@year, 6, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o2_sales = @o2.sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }

        @o2_commission = @employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", @o2_sales, @o2_sales)&.first&.rate.to_f * 0.01 * @o2_sales

        @o3 = Order.where(employee_id: @employee&.id).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 7, 1).beginning_of_month, Time.zone.local(@year, 9, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")
        
        @o3_sales = @o3.sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }
        
        @o3_commission = @employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", @o3_sales, @o3_sales)&.first&.rate.to_f * 0.01 * @o3_sales

        @o4 = Order.where(employee_id: @employee&.id).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 10, 1).beginning_of_month, Time.zone.local(@year, 12, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o4_sales = @o4.sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }
        
        @o4_commission = @employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", @o4_sales, @o4_sales)&.first&.rate.to_f * 0.01 * @o4_sales

      else
        @employees = Employee.where(exit_date: nil).where.not(sales_permission: nil)
        @o1 = Order.where(employee_id: @employees&.pluck(:id)).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 1, 1).beginning_of_month, Time.zone.local(@year, 3, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o1_sales = @employees.sum { |employee| @o1.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f } }

        @o1_commission = @employees.sum { |employee| employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", (@o1.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }), (@o1.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }))&.first&.rate.to_f * 0.01 * (@o1.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }) }

        @o2 = Order.where(employee_id: @employees&.pluck(:id)).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 4, 1).beginning_of_month, Time.zone.local(@year, 6, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o2_sales = @employees.sum { |employee| @o2.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f } }

        @o2_commission = @employees.sum { |employee| employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", (@o2.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }), (@o2.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }))&.first&.rate.to_f * 0.01 * (@o2.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }) }

        @o3 = Order.where(employee_id: @employees&.pluck(:id)).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 7, 1).beginning_of_month, Time.zone.local(@year, 9, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o3_sales = @employees.sum { |employee| @o3.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f } }

        @o3_commission = @employees.sum { |employee| employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", (@o3.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }), (@o3.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }))&.first&.rate.to_f * 0.01 * (@o3.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }) }

        @o4 = Order.where(employee_id: @employees&.pluck(:id)).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(@year, 10, 1).beginning_of_month, Time.zone.local(@year, 12, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")

        @o4_sales = @employees.sum { |employee| @o4.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f } }

        @o4_commission = @employees.sum { |employee| employee&.commission_rates&.where("lower_range <= ? AND upper_range > ?", (@o4.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }), (@o4.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }))&.first&.rate.to_f * 0.01 * (@o4.where(employee_id: employee.id).sum { |order| (order.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item.sku.include?("mulberry") || item.title.include?("Mulberry") || item.sku.include?("custom") || ShipmentCode.pluck(:sku_for_discount).include?(item.sku))).to_f }).to_f - (order.discount_codes["discount_amount"].to_f.abs if order.discount_codes.present?).to_f }) }
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def add_cem
    @invoice = Invoice.find_by(id: params[:invoice_id])
    @product = Product.find_by(id: params[:product_id])
    @product_variant = ProductVariant.where("length(sku) < 3 AND title ILIKE '%-%'").where.not("title ILIKE '%-%-%'").where.not("title ILIKE '%|%'").find_by(title: params[:category_name] + "-" + params[:material_name])
    if @product.product_variants.where("product_variants.sku ILIKE ?", "%" + @product_variant.sku).present?
      @invoice.invoice_line_items.create(product_variant_id: @product.product_variants.where("product_variants.sku ILIKE ?", "%" + @product_variant.sku).first.id, quantity: 0, price: 0)
    else
      @new_variant = @product&.product_variants&.first&.dup
      if @new_variant.present?
        @new_variant&.update(title: "CEM-" + @product.title + " " + @product_variant.title, price: nil, sku: "CEM-" + @product.sku + "-" + @product_variant.sku, inventory_quantity: nil, old_inventory_quantity: nil, unit_cost: nil, slug: (@product.title + " " + @product_variant.title).parameterize, inventory_limit: nil, variant_fulfillable: nil, discounted_price: nil, container_count: nil, special_price: nil, m2_product_id: nil, max_limit: nil, supplier_price: nil)
        @invoice.invoice_line_items.create(product_variant_id: @new_variant.id, quantity: 0, price: 0)
      end
    end
    redirect_to edit_admin_invoice_path(@invoice.id)
  end

  private

  def invoice_params
    params.require(:invoice).permit(:id, :order_id, :invoice_number, :status, :notes, :discount, :discount_amount, :tax_amount, :shipping_method, :employee_id, :shipping_type, :shipping_amount, :order_name, :customer_id, :source, :payment_method, :deposit, :additional_payment_method, :additional_deposit, :additional_notes, :no_sale_notes, invoice_line_items_attributes: [:id, :quantity])
  end
end