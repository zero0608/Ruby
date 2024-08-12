# frozen_string_literal: true
class Admin::OrdersController < ApplicationController
  include Pagy::Backend
  include Admin::OrdersHelper
  require 'pagy/extras/items'

  protect_from_forgery except: %i[shopify_order_sync tracking_order order_tracking shopify_order_update_sync orders_per_date]
  skip_before_action :authenticate_user!,
                      only: %i[shopify_order_sync tracking_order order_tracking shopify_order_update_sync
                              project_44_api orders_per_date]
  before_action :find_order, only: %i[edit show update destroy find_line_item delete_upload]
  before_action :find_line_item, only: %i[edit show update destroy]

  def index
    if current_user.user_group.orders_view
      if request.post?
        redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
      end
    
      @store1 = params[:store1]
      @date1 = Time.zone.parse(params[:date])
        
      @orders = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1).where("orders.created_at > ? AND orders.created_at < ?", @date1.beginning_of_day, @date1.end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")
      @compare_order = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1).where("orders.created_at > ? AND orders.created_at < ?", (@date1 - 1.day).beginning_of_day, (@date1 - 1.day).end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")
    
      @re = Issue.where(issue_type: :returns).where.not(status: 2).eager_load(:order).where(orders: { store: @store1 }).where("orders.created_at > ? AND orders.created_at < ?", @date1.beginning_of_day, @date1.end_of_day)
      @compare_re = Issue.where(issue_type: :returns).where.not(status: 2).eager_load(:order).where(orders: { store: @store1 }).where("orders.created_at > ? AND orders.created_at < ?", (@date1 - 1.day).beginning_of_day, (@date1 - 1.day).end_of_day)
    
      @chargeback = Issue.where(issue_type: :chargeback).where.not(status: 2).eager_load(:order).where(orders: { store: @store1 }).where("orders.created_at > ? AND orders.created_at < ?", @date1.beginning_of_day, @date1.end_of_day)
      @compare_chargeback = Issue.where(issue_type: :chargeback).where.not(status: 2).eager_load(:order).where(orders: { store: @store1 }).where("orders.created_at > ? AND orders.created_at < ?", (@date1 - 1.day).beginning_of_day, (@date1 - 1.day).end_of_day)
    
      @pending = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", @date1.beginning_of_day, @date1.end_of_day)
      @compare_pending = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", (@date1 - 1.day).beginning_of_day, (@date1 - 1.day).end_of_day)
    
      @cancel = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", @date1.beginning_of_day, @date1.end_of_day)
      @compare_cancel = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store1, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", (@date1 - 1.day).beginning_of_day, (@date1 - 1.day).end_of_day)
    
      @order_sum = @orders.sum { |order| order.total_amount.to_f }
    
      @compare_order_sum = @compare_order.sum { |order| order.total_amount.to_f }
    
      @return_sum = @re.sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i } * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f) - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max }
    
      @compare_return_sum = @compare_re.sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i } * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f) - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max }
    
      @chargeback_sum = @chargeback.sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }, 0].max }
    
      @compare_chargeback_sum = @compare_chargeback.sum { |issue| issue.full_refund ? [issue.total_amount.to_f, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }, 0].max }
    
      @pending_sum = @pending.sum { |order| order.total_amount.to_f }
    
      @compare_pending_sum = @compare_pending.sum { |order| order.total_amount.to_f }
    
      @cancel_sum = @cancel.sum { |order| order.total_amount.to_f }
    
      @compare_cancel_sum = @compare_cancel.sum { |order| order.total_amount.to_f }
    
      @store2 = params[:store2]
      @chart_sum1 = {}
      @chart_sum2 = {}
    
      if params[:ytd] == "true"
        for i in 1..12
          if i <= Time.now.month
            o1 = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").sum { |order| order.total_amount.to_f }
            
            o2 = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").sum { |order| order.total_amount.to_f } - Issue.where(issue_type: :returns).eager_load(:order).where(orders: { store: @store2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).sum { |issue| issue.full_refund ? [(issue.order.total_amount.to_f) - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i } * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f) - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max } - Issue.where(issue_type: :chargeback).eager_load(:order).where(orders: { store: @store2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }, 0].max } - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).sum { |order| order.total_amount.to_f } - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).sum { |order| order.total_amount.to_f }
            
            @chart_sum1.store(Date::MONTHNAMES[i], o1.round(2))
            @chart_sum2.store(Date::MONTHNAMES[i], o2.round(2))
          else
            @chart_sum1.store(Date::MONTHNAMES[i], 0)
            @chart_sum2.store(Date::MONTHNAMES[i], 0)
          end
        end
      else
        for i in 0..9
          o1 = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").sum { |order| order.total_amount.to_f }
    
          o2 = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").sum { |order| order.total_amount.to_f } - Issue.where(issue_type: :returns).eager_load(:order).where(orders: { store: @store2 }).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i } * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f) - (issue.order&.shipping_line&.price.to_f * (1 + (issue.order.tax_lines["rate"] if issue.order.tax_lines.present?).to_f)) - (issue.repacking_fee.to_f + issue.restocking_fee.to_f) - issue.returns.where.not(status: :cancelled).sum { |re| re.return_quote.to_f }, 0].max } - Issue.where(issue_type: :chargeback).eager_load(:order).where(orders: { store: @store2 }).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).sum { |issue| issue.full_refund ? [issue.order.total_amount.to_f, 0].max : [issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }, 0].max } - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).sum { |order| order.total_amount.to_f } - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).sum { |order| order.total_amount.to_f }
            
          @chart_sum1.store((Time.now - 9.days + i.days).strftime("%m-%d"), o1.round(2))
          @chart_sum2.store((Time.now - 9.days + i.days).strftime("%m-%d"), o2.round(2))
        end
      end
    
      @store2_2 = params[:store2_2]
      @chart_count1 = {}
      @chart_count2 = {}
        
      if params[:ytd_2] == "true"
        for i in 1..12
          if i <= Time.now.month
            o1_count = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").count
    
            o2_count = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").count - Issue.where(issue_type: :returns).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).count- Issue.where(issue_type: :chargeback).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).count- Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).count - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", Time.zone.local(Time.now.year, i, 1).beginning_of_month, Time.zone.local(Time.now.year, i, 1).end_of_month).count
    
            @chart_count1.store(Date::MONTHNAMES[i], o1_count)
            @chart_count2.store(Date::MONTHNAMES[i], o2_count)
          else
            @chart_count1.store(Date::MONTHNAMES[i], 0)
            @chart_count2.store(Date::MONTHNAMES[i], 0)
          end
        end
      else
        for i in 0..9
          o1_count = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").count
    
          o2_count = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%").count - Issue.where(issue_type: :returns).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).count - Issue.where(issue_type: :chargeback).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).count - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).count - Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", (Time.now - 9.days + i.days).beginning_of_day, (Time.now - 9.days + i.days).end_of_day).count
            
          @chart_count1.store((Time.now - 9.days + i.days).strftime("%m-%d"), o1_count)
          @chart_count2.store((Time.now - 9.days + i.days).strftime("%m-%d"), o2_count)
        end
      end
        
      @ytd_re_open = Issue.where(issue_type: :returns).where.not(status: 2).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
      @ytd_re_close = Issue.where(issue_type: :returns).where(status: 2).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
    
      @ytd_chargeback_open = Issue.where(issue_type: :chargeback).where.not(status: 2).eager_load(:order).where(orders: { store: @store2_2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
      @ytd_chargeback_close = Issue.where(issue_type: :chargeback).where(status: 2).eager_load(:order).where(orders: { store: @store2 }).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
    
      @ytd_pending = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :pending_payment).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
    
      @ytd_cancel = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store2_2, status: :cancel_confirmed).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_year, Time.now.end_of_day).count
    
      @store3 = params[:store3]
      @order3 = Order.where(order_type: [nil, "Unfulfillable", "Fulfillable"]).where(store: @store3).where("orders.created_at > ? AND orders.created_at < ?", Time.now.beginning_of_week, Time.now.end_of_week).where.not(status: [ :delayed, :hold_confirmed, :rejected, :hold_request, :pending_payment ]).where.not("name ILIKE ?", "R%")
        
      @products = Hash.new
      @order3.each do |order|
        order.line_items.where(order_from: nil).each do |line_item|
          if line_item.variant_id.present?
            if line_item.variant.sku.present?
              unless !(line_item.variant.sku.include? "-") || (line_item.variant.sku.include? "mulberry") || (line_item.variant.sku.include? "custom") || ShipmentCode.all.any? { |code| code.sku_for_discount.downcase == line_item.variant.sku.downcase }
                if @products[line_item.variant_id].present?
                  @products[line_item.variant_id] = @products[line_item.variant_id].to_i + line_item.quantity.to_i
                else
                  @products[line_item.variant_id] = line_item.quantity.to_i
                end
              end
            end
          end
        end
      end
    
      @store4 = params[:store4]
      @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', @store4, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31')).where.not(orders: { order_type: 'SW' }).eager_load(:order).joins(:order).where(status: 'shipped').where(shipped_date: (Time.now.at_beginning_of_week)..(Time.now.at_end_of_week))
    
      @states = Hash.new
      @shipping_details.each do |ship|
        state = ship.order.shipping_address.address2.strip.titleize if ship.try(:order).try(:shipping_address).try(:address2).present?
        if ship.order&.shipping_line&.title&.downcase&.include? "white glove" or ship.order.shipping_details.any? { |w| w.white_glove_delivery }
          amount = ship&.actual_invoiced.to_f + ship&.white_glove_fee.to_f + ship&.shipping_costs&.where(cost_type: "charges").sum(:amount)
        else
          amount = ship&.actual_invoiced.to_f + ship&.shipping_costs&.where(cost_type: "charges").sum(:amount)
        end
    
        if state.present? && @states[state].present?
          @states[state] = [@states[state][0].to_i + 1, @states[state][1].to_f + amount]
        else
          @states[state] = [1, amount]
        end
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def new
    @order = Order.new
    @order.shipping_details.build
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
    else
      render 'new'
    end
  end

  def edit
    Magento::UpdateOrder.new(@order.store).import_order_notes(@order) if @order.order_notes.nil?
    if current_user.user_group.orders_cru && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      ::Audited.store[:current_user] = current_user
      order_status_update(@order)
      update_order_type(@order)
      @users = User.all
      @orders = Order.where(order_type: [nil, 'Unfulfillable', 'Fulfillable']).where(store: current_store).first(10)
      @order ||= Order.find(params[:id])

      if @order.customer.first_name == "Guest"
        @order.customer.update(first_name: @order.billing_address.first_name, last_name: @order.billing_address.last_name)
      end

      @order.shipping_details.each do |s|
        if s.shipping_costs.empty?
          s.shipping_costs.create([{ cost_type: 'charges' }, { cost_type: 'fees' }])
        end
        s.pallet_shippings.create(order_id: @order.id, pallet_type: :loose_box) if s.pallet_shippings.empty?
        next unless s.shipping_quotes.empty?

        s.shipping_quotes.create
        s.shipping_quotes.create
        s.shipping_quotes.create
        s.shipping_quotes.create
        
        if s.status == "shipped"
          unless s.review_sections.where(white_glove: true).present?
            if s.white_glove_fee.present? && (s.white_glove_fee.to_f > 0)
              @review = ReviewSection.create(order_id: @order.id, store: @order.store, shipping_detail_id: s.id, invoice_type: s&.white_glove_directory&.company_name, white_glove: true)
              s.create_invoice_for_wgd
            end
          end
          unless s.review_sections.where(white_glove: false).present?
            if s&.shipping_quotes&.find_by(selected: true) && !s&.consolidation&.review_sections&.present?
              unless s&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Local" || s&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Factory to Customer" || s&.shipping_quotes&.find_by(selected: true)&.truck_broker&.name == "Accurate"
                if s.consolidation_id.present?
                  unless s.consolidation.review_sections.present?
                    @review = ReviewSection.create(consolidation_id: s.consolidation_id, store: @order.store, invoice_type: s&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                    s.consolidation.create_invoice_for_billing
                  end
                else
                  @review = ReviewSection.create(order_id: @order.id, store: @order.store, shipping_detail_id: s.id, invoice_type: s&.shipping_quotes&.find_by(selected: true)&.carrier&.name, white_glove: false)
                  s.create_invoice_for_billing
                end
              end
            end
          end
        end
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def update
    ::Audited.store[:current_user] = current_user
    @before_address = @order.shipping_address.complete_address if @order.shipping_address.present?
    if @order.update(order_params)
      if @order.shipping_details.where("shipping_details.eta_to > ?", Date.today).present?
        sd = @order.shipping_details.where("shipping_details.eta_to > ?", Date.today).order(:eta_from).first
        @order.update(eta_data_from: sd.eta_from, eta_data_to: sd.eta_to)
      end
      if @order.shipping_address.present?
        unless @order.shipping_address.address1.start_with?("[")
          @order.shipping_address.update(address1: '["' + @order.shipping_address.address1 + '"]')
        end
      end
      if params[:save_date].present? && params[:save_date] == 'Submit' && @order.hold_reason.present?
        @order.update(status: :hold_request)
        if @order.hold_until_date.present? && @order.hold_reason.present?
          UserNotification.with(order: @order, issue: 'nil', user: current_user, content: 'hold_request',
                              message: "#{@order.hold_until_date.to_date.strftime('%B %d, %Y')} - #{@order.hold_reason}", container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                                                                                                                      "notification_setting->>'hold_request' = ?", '1'
                                                                                                                                                    ))
        end
        redirect_to edit_admin_order_path(@order)

      elsif params[:save_reason].present? && params[:save_reason] == 'Submit'
        @order.update(status: :cancel_request)
        @order.update(cancel_request_date: Time.now)
        UserNotification.with(order: @order, issue: 'nil', user: current_user, content: 'cancel_request',
                              message: @order.cancel_reason, container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                                                          "notification_setting->>'cancel_request' = ?", '1'
                                                                                        ))
        redirect_to edit_admin_order_path(@order)
        Magento::UpdateOrder.new(@order.store).update_status(@order.shopify_order_id.to_s, @order.status.to_s)

      elsif params[:cancel_product].present? && params[:cancel_product][:item_ids].present?
        params[:cancel_product][:item_ids].each do |item_id|
          if LineItem.find(item_id).present?
            item = LineItem.find(item_id)
            item.update(cancel_request_check: :requested)
            ::Audited.store[:current_user] = User.find_by(email: 'admin@eternity-erp.com')
            @order.comments.create(description: "Cancel Request for #{item.title}(#{item.sku})", commentable_id: @order.id,  commentable_type: "Order")
          end
        end
        redirect_to edit_admin_order_path(@order)
      elsif params[:shipping_add_edit].present? && (@before_address != @order.shipping_address.complete_address)
        @order.comments.create(description: "Address edited from: #{@before_address} Updated: #{@order.shipping_address.complete_address}", commentable_id: @order.id,  commentable_type: "Order")
        redirect_to edit_admin_order_path
      else
        redirect_to edit_admin_order_path
      end
    else
      render 'edit'
    end
    if @order.status == 'new_order'
      order_status_update(@order)
      Magento::UpdateOrder.new(@order.store).update_status(@order.shopify_order_id.to_s, @order.status.to_s)
    end
    if params[:shipping_cost_edit].present? && !(@order.line_items.pluck(:quantity).reject(&:blank?).map(&:to_i).blank?) 
      @order.shipping_details.each do |ship|
        ::Audited.store[:current_user] = User.find_by(email: 'admin@eternity-erp.com')
        if ((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_f).sum) > 0) && (((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_f).sum) * 0.25) >= (((@order.line_items.pluck(:price).reject(&:blank?).map(&:to_f).zip(@order.line_items.pluck(:quantity).reject(&:blank?).map(&:to_f)).map{|x, y| x.to_f * y}).sum + @order.discount_codes["discount_amount"].to_f if @order.discount_codes.present?).to_f * 0.25))
          @order.comments.create(description: "NOTE: Shipping quote exceeds 25% of the order, $#{(((ship.actual_invoiced.to_f + ship.white_glove_fee.to_f + ship.shipping_costs.pluck(:amount).reject(&:blank?).map(&:to_f).sum)) - (((@order.line_items.pluck(:price).reject(&:blank?).map(&:to_f).zip(@order.line_items.pluck(:quantity).reject(&:blank?).map(&:to_f)).map{|x, y| x.to_f * y}).sum + @order.discount_codes["discount_amount"].to_f if @order.discount_codes.present?).to_f * 0.25))} over. Please get authorization before booking", commentable_id: @order.id, commentable_type: "Order")
        else
          ship.update(note: nil)
        end
      end
    end
    ::Audited.store[:current_user] = current_user
  end

  def show
    redirect_to edit_admin_order_path(@order)
  end

  def shopify_order_sync
    print 'order webhook.. started...'
    # hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    # store_type = request.headers['X-Shopify-Shop-Domain']
    data = request.body.read
    @store = store_country
    return head 403 unless webhook_verified?

    NewOrderWorker.perform_async(params[:order_id], @store) if !(Order.find_by(shopify_order_id: params[:order_id], store: @store).present?) && (@store.present?)
    render json: { status: 200, time: Time.now.getutc.to_s, request: request.url }
    # print "#{request.url}"
    print 'order webhook.. stopped...'
  end

  def shopify_order_update_sync
    print 'order webhook.. started...'
    # hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    # store_type = request.headers['X-Shopify-Shop-Domain']
    data = request.body.read
    @store = store_country
    return head 403 unless webhook_verified?

    OrderUpdateWorker.perform_async(params[:order_id], @store) if Order.find_by(
      _order_id: params[:order_id],
                                                                                store: @store).present? && @store.present?
    render json: { status: 200, time: Time.now.getutc.to_s }
    print 'order update webhook.. stopped...'
  end

  def tracking_order
    # data = request.body.read
    # order_info = JSON.parse(data)
    @track_order = Order.joins(:customer).where(name: params[:order_number].to_s,
                                                customers: { email: params[:email].to_s }).first
    # render html: @track_order
    @order_info = @track_order.to_json(include: { shipping_address: {}, billing_address: {}, shipping_line: {},
                                                  shipping_details: { include: { carrier: {}, line_items: { include: { purchase_items: { include: { containers: {} } }, variant: { include: { purchase_items: { include: { containers: {} } } } } } } } } })
    if !@track_order.nil?
      # render :partial => "/admin/orders/success_tracking_order"
      render partial: 'tracking', locals: { order: JSON.parse(@order_info) }
    else
      # render partial: "/admin/orders/fail_track_order"
      # render partial: "error"
      render html: 'false'
    end
    # render "https://eternitymodern.com/track-my-order"
    # render json: @track_order.to_json(include: {  shipping_address: {},  billing_address: {}, shipping_details: { include: { carrier: {}, line_items: {include: {purchase_items: { include: { containers: {}}}, variant: { include: { purchase_items: { include: { containers: {}}} }} }}} } })
  end

  def project_44_api
    # data = request.body.read
    # order_info = JSON.parse(data)
    @track_order = Order.joins(:customer).where(name: params[:order_number].to_s,
                                                customers: { email: params[:email].to_s }).first
    # render html: @track_order

    # @order_info = @track_order.to_json({ :person => { :firstName => "Yehuda", :lastName => "Katz" } })
    # if !(@track_order.nil?)
    #   #render :partial => "/admin/orders/success_tracking_order"
    #   render partial: "tracking", locals: {order: JSON.parse(@order_info)}
    # else
    #   #render partial: "/admin/orders/fail_track_order"
    #   #render partial: "error"
    #   render html: "false"
    # end
    # render "https://eternitymodern.com/track-my-order"
    # render json: @order_info
    render json: { destination: @track_order.shipping_address,
                    carrier_id: @track_order.shipping_details.pluck(:carrier_id), tracking_number: @track_order.shipping_details.pluck(:tracking_number), original_address: StoreAddress.first }
  end

  def order_tracking
    # data = request.body.read
    # order_info = JSON.parse(data)
    @track_order = Order.joins(:customer).where(name: params[:order_number].to_s,
                                                customers: { email: params[:email].to_s }).first
    @order_info = @track_order.to_json(include: { shipping_address: {}, billing_address: {}, shipping_line: {},
                                                  shipping_details: { include: { carrier: {}, line_items: { include: { purchase_items: { include: { containers: {} } }, variant: { include: { purchase_items: { include: { containers: {} } } } } } } } } })
    render json: @order_info
  end

  def get_all_orders
    HardWorker.perform_async(current_store)
    redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
  end

  def custom_orders
    if params[:variant_id].present?
      @product_variant = ProductVariant.find(params[:variant_id])
      # @product = Product.find(params[:product_id]) if params[:product_id].present?
      @orders = Order.eager_load(:line_items).joins(:line_items).where(store: current_store,
                                                                        order_type: 'Unfulfillable', line_items: { sku: @product_variant.sku, order_from: nil, status: 'not_started' })
    end
  end

  # def update_arriving
  #   SkuUpdateWorkerWorker.perform_async('var')
  #   redirect_to admin_orders_path
  # end

  # For deleting attachments
  def delete_upload
    attachment = ActiveStorage::Attachment.find_by(id: params[:doc_id])
    attachment.purge if attachment.present?
    redirect_to edit_admin_order_path(@order)
  end

  def shipping_list
    if params[:ship_ids].present?
      @shipping_details = ShippingDetail.eager_load(order: %i[customer shipping_details]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      case params[:ship_status]
      when 'staging'
        @shipping_details.update_all(printed_packing_slip: 1)
      when 'booked'
        @shipping_details.update_all(printed_bol: 1)
      end
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Packing slip #{Time.now}",
                  template: 'admin/orders/pdf.html.erb',
                  layout: 'pdf.html',
                  orientation: 'Portrait',
                  type: 'application/pdf',
                  print_media_type: true,
                  disposition: 'inline'
        end
      end
    elsif params[:sta].present?
      @shipping_detail = ShippingDetail.eager_load(order: %i[customer shipping_details]).joins(:order).where(
        id: params[:ship_id], orders: { store: current_store }
      )
      update_status(params[:ship_status])
      redirect_to shipping_list_admin_orders_path(ship_status: params[:ship_status])
    elsif params[:ship_status].present? && params[:ship_status] == 'shipped'
      if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
        @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31')).where.not(orders: { order_type: 'SW' })

        @shipping_details = @shipping_details.eager_load(:order).joins(:order).where(status: 'shipped').where(shipped_date: (Time.now.at_beginning_of_week)..(Time.now.at_end_of_week))
      else
        render 'dashboard/unauthorized'
      end
    elsif params[:ship_status].present? && params[:ship_status] == 'ready_to_ship'
      if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
        @white_glove_address ||= WhiteGloveAddress.new
        @ship_ids ||= ''
        @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31'))
        @shipping_details = @shipping_details.where(status: params[:ship_status])
        @shipping_details.each do |ship|
          next unless ship.order.eta.nil?

          ::Audited.store[:current_user] = current_user
          if ship.order.kind_of_order == nil
            if ship.order.kind_of_order == "QS"
              ship.order.update(eta: ship.order.created_at.to_date + 7.days)
            else
              ship.order.update(eta: ship.order.created_at.to_date + 112.days)
            end
          end
        end
        @state_filter ||= ""
      else
        render 'dashboard/unauthorized'
      end
    elsif params[:ship_status].present? && params[:ship_status] == 'ready_for_pickup'
      if current_user.user_group.dc_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
        @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not(
          'line_items.created_at < ?', Date.parse('2021-10-31')
        )
        @shipping_details = @shipping_details.eager_load(:line_items).joins(:line_items).where(
          '(line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?)', 'WAREHOUSE-HOLD', 'RECONSIGNMENT-FEE', 'SHIPPING-FOR-COM', 'REMOTE-SHIPPING', 'REDELIVERY-FEE', 'HANDLING-FEE', 'STORAGE-FEE', 'WGS001', 'E-PMNT'
        )
        @shipping_details = @shipping_details.where(status: "ready_for_pickup")
      else
        render 'dashboard/unauthorized'
      end
    elsif params[:ship_status].present? && params[:ship_status] == 'not_ready'
      if current_user.user_group.dc_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
        @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31'))

        @shipping_details = @shipping_details.eager_load(:line_items).joins(:line_items).where('(line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?) or (line_items.sku NOT LIKE ?)', 'WAREHOUSE-HOLD', 'RECONSIGNMENT-FEE', 'SHIPPING-FOR-COM', 'REMOTE-SHIPPING', 'REDELIVERY-FEE', 'HANDLING-FEE', 'STORAGE-FEE', 'WGS001', 'E-PMNT')

        @pagy, @shipping_details = pagy(@shipping_details.where(status: "not_ready"), items_param: :per_page, max_items: 100)
      else
        render 'dashboard/unauthorized'
      end
    elsif current_user.user_group.dc_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where.not(status: 'cancelled', orders: { status: %w[cancel_request cancel_confirmed hold_request hold_confirmed completed] }).where.not('line_items.created_at < ?', Date.parse('2021-10-31'))

      @shipping_details = @shipping_details.eager_load(:line_items).joins(:line_items).where('(line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?) and (line_items.sku NOT ILIKE ?)', 'WAREHOUSE-HOLD', 'RECONSIGNMENT-FEE', 'SHIPPING-FOR-COM', 'REMOTE-SHIPPING', 'REDELIVERY-FEE', 'HANDLING-FEE', 'STORAGE-FEE', 'WGS001', 'E-PMNT')
      
      @shipping_details = @shipping_details.where(status: params[:ship_status])
      @state_filter ||= ""
    else
      render 'dashboard/unauthorized'
    end
  end

  def update_status(ship_status)
    case ship_status
    when 'staging'
      @shipping_detail.update_all(status: 'ready_to_ship')
    when 'ready_to_ship'
      @shipping_detail.update_all(status: 'booked')
    when 'booked'
      @shipping_details.update_all(status: 'ready_for_pickup')
    when 'ready_for_pickup'
      @shipping_detail.update_all(status: 'shipped')
      @line_items = LineItem.where(shipping_detail_id: params[:ship_id], order_from: nil)
      @line_items.update_all(status: 'shipped')
    end
  end

  def stock
    if current_user.user_group.inventory_view && current_user.user_group.permission_us
      @current_user = current_user
      if params[:return_status] == "overstock"
        @returns = ReturnProduct.where(store: "us").where("return_products.quantity > 0")
      elsif params[:return_status] == "marketplace"
        @market_products = MarketProduct.eager_load(:order).where(orders: { store: "us" }).where(status: :pending).where.not(line_item_id: nil)
        if params[:market_product_id].present?
          @market_product = MarketProduct.find_by(id: params[:market_product_id])
        end
      else
        if params[:type] == "swatch"
          @pagy, @line_items = pagy(ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) < 3)", "us", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc), items_param: :per_page, max_items: 100)
        else
          @pagy, @line_items = pagy(ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) > 2)", "us", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc), items_param: :per_page, max_items: 100)
        end
        if request.format == 'csv' && (params[:report_type] == 'stock')
          @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "us", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc)
        end
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def emca_stock
    if current_user.user_group.inventory_view && current_user.user_group.permission_ca
      @current_user = current_user
      if params[:return_status] == "overstock"
        @returns = ReturnProduct.where(store: "canada").where("return_products.quantity > 0")
      elsif params[:return_status] == "marketplace"
        @market_products = MarketProduct.eager_load(:order).joins(:order).where(orders: { store: "canada" }).where.not(line_item_id: nil)
        if params[:market_product_id].present?
          @market_product = MarketProduct.find_by(id: params[:market_product_id])
        end
      else
        if params[:type] == "swatch"
          @pagy, @line_items = pagy(ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) < 3)", "canada", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc), items_param: :per_page, max_items: 100)
        else
          @pagy, @line_items = pagy(ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (length(product_variants.sku) > 2)", "canada", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc), items_param: :per_page, max_items: 100)
        end
        if request.format == 'csv' && (params[:report_type] == 'stock')
          @line_items = ProductVariant.eager_load(:purchase_items).joins(:product).where(
            "(product_variants.store LIKE ?) and (product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "canada", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "COM-%", "CST-%"
          ).order(created_at: :desc)
        end
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def warehouse_inventories
    if params[:warehouse_name].present?
      @pagy, @warehouse_variants = pagy(
        WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).find_by_name(params[:warehouse_name]).id).order(created_at: :desc), items_param: :per_page, max_items: 100
      )
    else
      @pagy, @warehouse_variants = pagy(
        WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).first.id).order(created_at: :desc), items_param: :per_page, max_items: 100
      )
    end
  end

  def emca_warehouse_inventories
    if params[:warehouse_name].present?
      @pagy, @warehouse_variants = pagy(
        WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).find_by_name(params[:warehouse_name]).id).order(created_at: :desc), items_param: :per_page, max_items: 100
      )
    else
      @pagy, @warehouse_variants = pagy(
        WarehouseVariant.where(store: current_store, warehouse_id: Warehouse.where(store: current_store).first.id).order(created_at: :desc), items_param: :per_page, max_items: 100
      )
    end
  end

  def alert
    if current_user.user_group.inventory_view
      @variants = ProductVariant.where.not(inventory_limit: nil)
      @variants = @variants.eager_load(:product).joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%warranty%", "WGS001", "HLD001", "HFE001").where("inventory_quantity = inventory_limit").where.not(product_id: nil)
    else
      render 'dashboard/unauthorized'
    end
  end

  def order_status
    ::Audited.store[:current_user] = current_user
    if params[:status].present? && params[:name].present?
      @order = Order.find_by(name: params[:name])
      case params[:status]
      when 'cancel_request'
        @order.update(status: :cancel_request)
        @order.update(cancel_request_date: Time.now)
        UserNotification.with(order: @order, issue: 'nil', user: current_user, content: 'cancel_request',
                              container: 'nil').deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'cancel_request' = ?",
                                                                                                    '1'))
        redirect_to edit_admin_order_path(name: @order.name)
      when 'cancel_confirmed'
        @order.update(status: :cancel_confirmed)
        @order.shipping_details.update_all(status: :cancelled)
        Magento::UpdateOrder.new(@order.store).cancel_order_to_m2(@order)
        UserNotification.with(order: @order, issue: "nil", user: current_user, content: "cancel_confirm", container: "nil").deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'cancel_confirm' = ?", "1"))

        @order.line_items.each do |item|
          if item.status == "ready" && item.variant_id.present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            @product_variant.update(inventory_quantity: (item.quantity.to_i + @product_variant.inventory_quantity.to_i))
            @product_variant.update(to_do_quantity: (@product_variant&.to_do_quantity.to_i - item.quantity.to_i))
            item.warehouse_variant.update(warehouse_quantity: item.warehouse_variant.warehouse_quantity.to_i + item.quantity.to_i) if item.warehouse_variant.present?
            if @product_variant.cartons.present?
              @product_variant.cartons.each do |carton|
                carton.update(to_do_quantity: (carton&.to_do_quantity.to_i - item.quantity.to_i))
              end
            end

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i, warehouse_id: item&.warehouse_variant&.warehouse&.id, warehouse_adjustment: item.quantity, warehouse_quantity: item&.warehouse_variant&.warehouse_quantity)
            Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
            Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

          elsif item.status == "in_production" && item.purchase_item_id.present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            purchase_item = PurchaseItem.find(item.purchase_item_id)
            purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: @product_variant.inventory_quantity)

          elsif item.status == "in_production" && PurchaseItem.find_by(line_item_id: item.id).present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            @purchase_item = PurchaseItem.find_by(line_item_id: item.id)

            if @purchase_item.purchase.store == "us"
              @purchase_item.update(purchase_type: "TUS")
            else
              @purchase_item.update(purchase_type: "TCA")
            end
            @purchase_item.update(line_item_id: nil)

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
            Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
            Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

          elsif item.status == "container_ready" && item.purchase_item_id.present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            purchase_item = PurchaseItem.find(item.purchase_item_id)
            purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: @product_variant.inventory_quantity)

          elsif item.status == "container_ready" && PurchaseItem.find_by(line_item_id: item.id).present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            @purchase_item = PurchaseItem.find_by(line_item_id: item.id)

            if @purchase_item.containers.present?
              @container = @purchase_item.containers.last
              if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
                @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).last
                @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
                @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
              elsif @purchase_item.purchase.store == "us"
                @purchase_item.update(purchase_type: "TUS")
                @purchase_item.update(line_item_id: nil)
              else
                @purchase_item.update(purchase_type: "TCA")
                @purchase_item.update(line_item_id: nil)
              end
            elsif @purchase_item.purchase.store == "us"
              @purchase_item.update(purchase_type: "TUS")
              @purchase_item.update(line_item_id: nil)
            else
              @purchase_item.update(purchase_type: "TCA")
              @purchase_item.update(line_item_id: nil)
            end

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
            Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
            Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

          elsif item.status == "en_route" && item.container_id.present? && item.variant_id.present? && item.container.status != "arrived"
            if item.purchase_item_id.present?
              @product_variant = ProductVariant.find_by(id: item.variant_id)
              purchase_item = PurchaseItem.find(item.purchase_item_id)
              purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))

              InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
              Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
              Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

            elsif item.container_id.present?
              @container = Container.find(item.container_id)
              purchase_item = @container.purchase_items.where(product_variant_id: item.variant_id).first
              @product_variant = ProductVariant.find_by(id: item.variant_id)
              purchase_item = PurchaseItem.find(item.purchase_item_id)
              purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))
              InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
              Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
              Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
            end

          elsif item.status == "en_route" && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present? && PurchaseItem.find_by(line_item_id: item.id).containers.where.not(containers: { status: "arrived" }).present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
            if @purchase_item.containers.present?
              @container = @purchase_item.containers.last
              if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
                @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).last
                @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
                @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
              elsif @purchase_item.purchase.store == "us"
                @purchase_item.update(purchase_type: "TUS")
                @purchase_item.update(line_item_id: nil)
              else
                @purchase_item.update(purchase_type: "TCA")
                @purchase_item.update(line_item_id: nil)
              end
            elsif @purchase_item.purchase.store == "us"
              @purchase_item.update(purchase_type: "TUS")
              @purchase_item.update(line_item_id: nil)
            else
              @purchase_item.update(purchase_type: "TCA")
              @purchase_item.update(line_item_id: nil)
            end

            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
            Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
            Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

          elsif item.status == "not_started" && item.purchase_item_id.present?
            purchase_item = PurchaseItem.find_by(line_item_id: item.id)
            purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.quantity&.to_i))

          elsif item.status == "not_started" && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present?
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
            if @purchase_item.purchase.store == "us"
              @purchase_item.update(purchase_type: "TUS")
            else
              @purchase_item.update(purchase_type: "TCA")
            end
            @purchase_item.update(line_item_id: nil)
            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
            Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
            Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

          elsif item.status == "not_started"
            @product_variant = ProductVariant.find_by(id: item.variant_id)
            InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Order Cancelled", adjustment: item.quantity, quantity: @product_variant.inventory_quantity)
          end
        end

        @order.line_items.update_all(status: :cancelled)
        @order.shipping_details.update_all(status: :cancelled)

        @order.update(cancelled_date: Time.now)
        redirect_to cancel_request_admin_orders_path(type: "cancel_request")
      when 'reject'
        @order.update(status: :in_progress)
        redirect_to cancel_request_admin_orders_path(type: "cancel_request")
      when 'hold_confirmed'
        @order.update(status: :hold_confirmed)
        @order.shipping_details.update_all(status: :hold)
        UserNotification.with(order: @order, issue: 'nil', user: current_user, content: 'hold_confirm',
                              container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                          "notification_setting->>'hold_confirm' = ?", '1'
                                                        ))
        redirect_to hold_request_admin_orders_path
      when 'hold_reject'
        @order.update(status: :in_progress)
        redirect_to hold_request_admin_orders_path
      when 'unhold'
        @order.update(status: :in_progress)
        @order.shipping_details.update_all(status: :ready_to_ship)
        redirect_to hold_request_admin_orders_path
      else
        redirect_to shipping_list_admin_orders_path(ship_status: "not_ready")
      end
    elsif params[:ship_ids].present? && params[:ship_status] == 'ready_for_pickup'
      @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      if @shipping_details.present?
        @shipping_details.each do |ship|
          ship.update(status: :ready_for_pickup)
        end
      end
      @shipping_details.each do |sd|
        Magento::UpdateOrder.new(sd.order.store).update_status(sd.order.shopify_order_id.to_s, sd.order.status.to_s)
      end
      redirect_to shipping_list_admin_orders_path(ship_status: 'booked')
    elsif params[:ship_ids].present? && params[:ship_status] == 'staging'
      @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      @shipping_details.update_all(status: :booked) if @shipping_details.present?
      @shipping_details.each do |sd|
        Magento::UpdateOrder.new(sd.order.store).update_status(sd.order.shopify_order_id.to_s, sd.order.status.to_s)
      end
      redirect_to shipping_list_admin_orders_path(ship_status: 'staging')
    elsif params[:ship_ids].present? && params[:ship_status] == 'ready_to_ship'
      @order_name = []
      @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      @shipping_details.update_all(status: :ready_to_ship) if @shipping_details.present?
      @shipping_details.each do |sd|
        @order_name.push sd.order.name
        Magento::UpdateOrder.new(sd.order.store).update_status(sd.order.shopify_order_id.to_s, sd.order.status.to_s)
      end
      unless @order_name.nil?
        if @order_name.count == 1
          UserNotification.with(order: Order.find_by(name: @order_name[0]), issue: 'nil', user: current_user,
                                content: 'one_ready_to_ship', container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                                                          "notification_setting->>'ready_to_ship' = ?", '1'
                                                                                        ))
        else
          UserNotification.with(order: @order_name, issue: 'nil', user: current_user, content: 'many_ready_to_ship',
                                container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                            "notification_setting->>'ready_to_ship' = ?", '1'
                                                          ))
        end
      end
      redirect_to shipping_list_admin_orders_path(ship_status: 'staging')
    elsif params[:ship_ids].present? && params[:ship_status] == 'booked'
      @order_name = []
      @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      @shipping_details.update_all(status: :booked) if @shipping_details.present?
      @shipping_details.each do |sd|
        state = StateDay.find_by("LOWER(state_days.state) = ? OR LOWER(state_days.name) = ?", sd.order.shipping_address.address2&.downcase, sd.order.shipping_address.address2&.downcase)
        
        sd.update(eta_from: Date.today + (state&.start_days.present? ? state&.start_days&.to_i.days : 5.days), eta_to: Date.today + (state&.end_days.present? ? state&.end_days&.to_i.days : 10.days))

        @order_name.push sd.order.name
        Magento::UpdateOrder.new(sd.order.store).update_status(sd.order.shopify_order_id.to_s, sd.order.status.to_s)
      end
      unless @order_name.nil?
        if @order_name.count == 1
          UserNotification.with(order: Order.find_by(name: @order_name[0]), issue: 'nil', user: current_user,
                                content: 'one_booked', container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                                                    "notification_setting->>'booked' = ?", '1'
                                                                                  ))
        else
          UserNotification.with(order: @order_name, issue: 'nil', user: current_user, content: 'many_booked',
                                container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                            "notification_setting->>'booked' = ?", '1'
                                                          ))
        end
      end
      redirect_to shipping_list_admin_orders_path(ship_status: 'ready_to_ship')
    elsif params[:ship_ids].present? && params[:ship_status] == 'shipped'
      @order_name = []
      @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
        id: params[:ship_ids].split(','), orders: { store: current_store }
      )
      @shipping_details.update_all(status: :shipped) if @shipping_details.present?
      @shipping_details.update_all(shipped_date: Date.today) if @shipping_details.present?
      @shipping_details.each do |sd|
        @order_name.push sd.order.name
        Magento::UpdateOrder.new(sd.order.store).update_status(sd.order.shopify_order_id.to_s, sd.order.status.to_s)
        @order = Order.find_by_name(sd.order.name)
        if sd.status == "shipped"
          unless sd.review_sections.where(white_glove: true).present?
            if sd.white_glove_fee.present? && (sd.white_glove_fee.to_f > 0)
              @review = ReviewSection.create(order_id: @order.id, store: @order.store, shipping_detail_id: sd.id, invoice_type: sd&.white_glove_directory&.company_name, white_glove: true)
              sd.create_invoice_for_wgd
            end
          end
          unless sd.review_sections.where(white_glove: false).present?
            if sd&.shipping_quotes&.find_by(selected: true) && !sd&.consolidation&.review_sections&.present?
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
        unless sd.status == 'shipped' && sd.map_id.nil? && sd.carrier.present? && sd.carrier.tracking_url.present?
          next
        end

        sd.update(tracking_url_for_ship: sd.carrier.tracking_url)
        if sd.tracking_url_for_ship.present? && (sd.status == 'shipped')
          Magento::UpdateOrder.new(sd.order.store).create_shipment(sd.order, sd)
        end
      end
      unless @order_name.nil?
        if @order_name.count == 1
          UserNotification.with(order: Order.find_by(name: @order_name[0]), issue: 'nil', user: current_user,
                                content: 'one_shipped', container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                                                    "notification_setting->>'shipped' = ?", '1'
                                                                                  ))
        else
          UserNotification.with(order: @order_name, issue: 'nil', user: current_user, content: 'many_shipped',
                                container: 'nil').deliver(User.where(deactivate: [false, nil]).where(
                                                            "notification_setting->>'shipped' = ?", '1'
                                                          ))
        end
      end
      redirect_to shipping_list_admin_orders_path(ship_status: 'ready_for_pickup')
    elsif params[:item_id].present? && params[:status] == 'product_cancel_confirmed'
      item = LineItem.find_by(id: params[:item_id])
      @order = item.order
      if item.status == "ready" && item.variant_id.present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        @product_variant.update(inventory_quantity: (@product_variant.inventory_quantity.to_i + item&.cancel_quantity.to_i))
        @product_variant.update(to_do_quantity: (@product_variant&.to_do_quantity.to_i - item&.cancel_quantity.to_i))
        if @product_variant.cartons.present?
          @product_variant.cartons.each do |carton|
            carton.update(to_do_quantity: (carton&.to_do_quantity.to_i - item&.cancel_squantity.to_i))
          end
        end
        
        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
        Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
        Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

      elsif item.status == "in_production" && item.purchase_item_id.present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        purchase_item = PurchaseItem.find(item.purchase_item_id)
        purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.cancel_quantity&.to_i))

        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: @product_variant.inventory_quantity)

      elsif item.status == "in_production" && PurchaseItem.find_by(line_item_id: item.id).present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        @purchase_item = PurchaseItem.find_by(line_item_id: item.id)

        if @purchase_item.purchase.store == "us"
          @purchase_item.update(purchase_type: "TUS")
        else
          @purchase_item.update(purchase_type: "TCA")
        end
        @purchase_item.update(line_item_id: nil)

        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
        Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
        Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

      elsif item.status == "container_ready" && item.purchase_item_id.present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        purchase_item = PurchaseItem.find(item.purchase_item_id)
        purchase_item.update(quantity: (purchase_item&.quantity&.to_i + item&.cancel_quantity&.to_i))
        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: @product_variant.inventory_quantity)

      elsif item.status == 'container_ready' && PurchaseItem.find_by(line_item_id: item.id).present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        @purchase_item = PurchaseItem.find_by(line_item_id: item.id)

        if @purchase_item.containers.present?
          @container = @purchase_item.containers.last
          if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
            @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).last
            @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
            @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
          elsif @purchase_item.purchase.store == "us"
            @purchase_item.update(purchase_type: "TUS")
            @purchase_item.update(line_item_id: nil)
          else
            @purchase_item.update(purchase_type: "TCA")
            @purchase_item.update(line_item_id: nil)
          end
        elsif @purchase_item.purchase.store == "us"
          @purchase_item.update(purchase_type: "TUS")
          @purchase_item.update(line_item_id: nil)
        else
          @purchase_item.update(purchase_type: "TCA")
          @purchase_item.update(line_item_id: nil)
        end
        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id,event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
        Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
        Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

      elsif item.status == "en_route" && item.container_id.present? && item.variant_id.present? && item.container.status != "arrived"
        if item.purchase_item_id.present?
          @product_variant = ProductVariant.find_by(id: item.variant_id)
          purchase_item = PurchaseItem.find(item.purchase_item_id)
          purchase_item.update(quantity: (purchase_item&.quantity.to_i + item&.cancel_quantity.to_i))

          InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: @product_variant.inventory_quantity)
          Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
          
        elsif item.container_id.present?
          @container = Container.find(item.container_id)
          purchase_item = @container.purchase_items.where(product_variant_id: item.variant_id).first
          @product_variant = ProductVariant.find_by(id: item.variant_id)
          purchase_item = PurchaseItem.find(item.purchase_item_id)
          purchase_item.update(quantity: (purchase_item&.quantity.to_i + item&.cancel_quantity.to_i))
          InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: @product_variant.inventory_quantity)
          Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
          Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
        end

      elsif item.status == "en_route" && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present? && PurchaseItem.find_by(line_item_id: item.id).containers.where.not(containers: { status: "arrived" }).present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
        if @purchase_item.containers.present?
          @container = @purchase_item.containers.last
          if @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).present?
            @p_item = @container.purchase_items.where(product_variant_id: @product_variant.id, line_item_id: nil).last
            @p_item.update(quantity: (@p_item.quantity + @purchase_item.quantity))
            @purchase_item.update(line_item_id: nil, product_variant_id: nil, product_id: nil)
          elsif @purchase_item.purchase.store == 'us'
            @purchase_item.update(purchase_type: 'TUS')
            @purchase_item.update(line_item_id: nil)
          else
            @purchase_item.update(purchase_type: 'TCA')
            @purchase_item.update(line_item_id: nil)
          end
        elsif @purchase_item.purchase.store == 'us'
          @purchase_item.update(purchase_type: 'TUS')
          @purchase_item.update(line_item_id: nil)
        else
          @purchase_item.update(purchase_type: 'TCA')
          @purchase_item.update(line_item_id: nil)
        end

        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
        Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
        Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)

      elsif item.status == "not_started" && item.purchase_item_id.present?
        purchase_item = PurchaseItem.find_by(line_item_id: item.id)
        purchase_item.update(quantity: (purchase_item&.quantity.to_i + item&.cancel_quantity.to_i))

      elsif item.status == "not_started" && item.variant_id.present? && PurchaseItem.find_by(line_item_id: item.id).present?
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        @purchase_item = PurchaseItem.find_by(line_item_id: item.id)
        if @purchase_item.purchase.store == "us"
          @purchase_item.update(purchase_type: "TUS")
        else
          @purchase_item.update(purchase_type: "TCA")
        end
        @purchase_item.update(line_item_id: nil)
        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Cancelled", adjustment: item&.cancel_quantity.to_i, quantity: ProductVariant.find_by(id: item.variant_id).inventory_quantity.to_i)
        Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
        Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
      elsif item.status == "not_started"
        @product_variant = ProductVariant.find_by(id: item.variant_id)
        InventoryHistory.create(order_id: @order.id, product_variant_id: @product_variant.id, user_id: current_user.id, event: "Product Canceled", adjustment: item&.cancel_quantity.to_i, quantity: @product_variant.inventory_quantity)
      end
      if item.cancel_quantity.to_i < item.quantity.to_i
        item.update(cancel_request_check: :partial_cancelled)
      else
        item.update(cancel_request_check: :item_cancelled, status: :cancelled)
      end
      redirect_to cancel_request_admin_orders_path(type: "cancel_product")

    elsif params[:item_id].present? && params[:status] == 'product_reject'
      LineItem.find_by(id: params[:item_id]).update(cancel_request_check: nil)
      redirect_to cancel_request_admin_orders_path(type: "cancel_product")
    end
  end

  def cancel_request
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      @orders = Order.where(status: :cancel_request, store: current_store)
      @confirmed = Order.where(status: %i[cancel_confirmed rejected], store: current_store).where.not('orders.created_at < ?', Date.today - 30.days)
      @line_items = LineItem.where(store: current_store).where.not(status: [:cancelled]).where(cancel_request_check: :requested)
    else
      render 'dashboard/unauthorized'
    end
  end

  def cancel_confirmed
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      @request = Order.where(status: :cancel_request, store: current_store)
      @orders = Order.where(status: %i[cancel_confirmed rejected], store: current_store).where.not('orders.created_at < ?', Date.today - 30.days)
      @line_items = LineItem.where(store: current_store).where.not(status: :cancelled)
    else
      render 'dashboard/unauthorized'
    end
  end

  def hold_request
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      @orders = Order.where(status: :hold_request, store: current_store)
    else
      render 'dashboard/unauthorized'
    end
  end

  def hold_confirmed
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      @orders = Order.where(status: :hold_confirmed, store: current_store)
    else
      render 'dashboard/unauthorized'
    end
  end

  def completed
    @orders = Order.where(status: :completed, store: current_store)
  end

  def pdf
    @shipping_details = ShippingDetail.eager_load(:line_items, order: [:customer]).joins(:order).where(
      id: params[:ship_ids].split(','), orders: { store: current_store }
    )

    case params[:ship_status]
    when 'staging'
      @shipping_details.update_all(printed_packing_slip: 1)
    when 'booked'
      @shipping_details.update_all(printed_bol: 1)
    when 'ready_to_ship'
      @merge_packing_slip = MergePackingSlip.find_by(id: params[:merge_id])
      @directory = WhiteGloveAddress.find_by(id: params[:directory_id])
    end
  end

  def reserved_skus
    ::Audited.store[:current_user] = current_user
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      if params[:id].present?
        @line_item = LineItem.find_by(id: params[:id])
        @line_item.update_column(:reserve, params[:reserve].to_i)
        redirect_to reserved_skus_admin_orders_path
      end

      @reserved_line_items = LineItem.eager_load(:order).joins(:order).where(status: :ready, orders: { store: current_store, order_type: 'Unfulfillable' }).where.not(orders: { status: 'cancel_confirmed' }).joins(:shipping_detail).where(shipping_details: { status: 'not_ready' }).where('length(sku) > 2')

      @reserved_line_items = @reserved_line_items.where('(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)', '%Get Your Swatches%', '%warranty%', 'WGS001', 'HLD001', 'HFE001', 'Handling Fee', 'Cotton', 'Wheat', 'velvet', 'Weave', 'Performance')

      @reserved_line_items.each do |li|
        li.update(reserve: false) if li.reserve.nil?
      end

      case params[:reserve_status]
        when "reserved"
          @reserved_line_items = @reserved_line_items.where(reserve: true)
        when "to_be_reserved"
          @reserved_line_items = @reserved_line_items.where(reserve: false)
      end

      @reserved = LineItem.eager_load(:order).joins(:order).where(status: :ready, orders: { store: current_store, order_type: "Unfulfillable" }).where.not(orders: {status: "cancel_confirmed"}).joins(:shipping_detail).where(shipping_details: {status: "not_ready"}).where("length(sku) > 2").where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee", "Cotton", "Wheat", "velvet", "Weave", "Performance").where(reserve: true)
      
      @to_be_reserved = LineItem.eager_load(:order).joins(:order).where(status: :ready, orders: { store: current_store, order_type: "Unfulfillable" }).where.not(orders: {status: "cancel_confirmed"}).joins(:shipping_detail).where(shipping_details: {status: "not_ready"}).where("length(sku) > 2").where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee", "Cotton", "Wheat", "velvet", "Weave", "Performance").where(reserve: false)
    else
      render 'dashboard/unauthorized'
    end
  end

  def swatches_page
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      if params[:swatch_item_ids].present?
        @line_items = LineItem.eager_load(order: [:customer]).joins(:order).where(
          id: params[:swatch_item_ids].split(','), orders: { store: current_store }
        )
        @line_items.update_all(clear_swatch: 1)
        redirect_to swatches_page_admin_orders_path
      else
        @line_items = LineItem.eager_load(:order).where(order_from: nil, clear_swatch: nil,
                                                        orders: { store: current_store }).order(created_at: :desc)
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def print_swatch_table
    @line_items = LineItem.eager_load(order: [:customer]).joins(:order).where(id: params[:swatch_item_ids].split(','),
                                                                              orders: { store: current_store })
  end

  def pending_payment_section
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == 'us') || (current_user.user_group.permission_ca && current_store == 'canada'))
      case params[:pending_status]
      when '1-3'
        @orders = Order.where(store: current_store, status: :pending_payment).where("DATE(created_at) >= ? AND DATE(created_at) <= ?", Date.today - 3.days, Date.today)
      when '4-6'
        @orders = Order.where(store: current_store, status: :pending_payment).where("DATE(created_at) >= ? AND DATE(created_at) <= ?", Date.today - 6.days, Date.today - 4.days)
      when '7-13'
        @orders = Order.where(store: current_store, status: :pending_payment).where("DATE(created_at) >= ? AND DATE(created_at) <= ?", Date.today - 13.days, Date.today - 7.days)
      when '14+'
        @orders = Order.where(store: current_store, status: :pending_payment).where("DATE(created_at) >= ? AND DATE(created_at) <= ?", Date.new(2020, 10, 31), Date.today - 14.days)
      else
        @orders = Order.where(store: current_store, status: :pending_payment)
      end
    else
      render 'dashboard/unauthorized'
    end
  end

  def update_order_status_to_m2
    orders = Order.where(order_type: 'Fulfillable', sent_mail: nil)
    orders.each(&:send_status_to_m2_qs) if orders.present?
  end

  def update_order_status_to_m2_mto
    orders = Order.where(order_type: 'Unfulfillable')
    orders.each(&:send_status_to_m2_mto) if orders.present?
  end

  def unfulfillable
    @orders = Order.eager_load(:customer, :shipping_details, :shipping_line).where(store: current_store,
                                                                                    order_type: 'Unfulfillable').where.not(status: %w[
                                                                                                                            cancel_confirmed completed
                                                                                                                          ]).order(eta: :asc)
  end

  def report
    @report_start_date ||= Date.today.to_datetime.at_beginning_of_day + 8.hours
    @report_end_date ||= Date.today.to_datetime.at_end_of_day + 8.hours
    @report_label ||= 'Select Time'
    case params[:report_type]
    when "price_carton"
      @product_variants = ProductVariant.where(store: current_store).where("(product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "WS-%")
      
    when "inventory"
      @product_variants = ProductVariant.eager_load(:purchase_items).joins(:product).where("(product_variants.title NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", "Default Title", "%warranty%", "WGS001", "HLD001", "HFE001", "WR-%").order(created_at: :desc)

      if params[:store].present?
        @product_variants = @product_variants.where(store: params[:store])
      end

      if params[:stock].present?
        @product_variants = @product_variants.where(stock: params[:stock])
      end

    when "overstock"
      @product_variants = ProductVariant.where("(product_variants.store LIKE ?) and (product_variants.sku LIKE ?)", current_store, "WR-%").order(created_at: :desc)
    when 'order'
      @orders = Order.eager_load(:customer, :shipping_details, :shipping_line).where(store: current_store).order(created_at: :desc).where(
        '(orders.created_at > ?) and (orders.created_at < ?)', params[:report_start_date], params[:report_end_date]
      )
    when 'shipment'
      @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil).where(
        '(shipping_details.created_at > ?) and (shipping_details.created_at < ?)', params[:report_start_date], params[:report_end_date]
      )
    when 'issue'
      @issues = Issue.eager_load(:order).joins(:order).where(orders: { store: current_store }).where.not(status: 'closed').where(
        '(issues.created_at > ?) and (issues.created_at < ?)', params[:report_start_date], params[:report_end_date]
      )
    when 'container'
      @containers = Container.where('(containers.created_at > ?) and (containers.created_at < ?)',
                                    params[:report_start_date], params[:report_end_date])
    end
  end

  def report_logistics
    @year = params[:year].to_i
    if @year <= Date.today.year
      @us_overview = ShippingDetail.where('extract(year from shipping_details.created_at) = ?', @year).joins(:order).where(orders: { store: 'us', status: 'completed' }).eager_load(:line_items).where.not(
        '(line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?)', 'CUSTOMIZATION-FEE', 'E-PMNT', 'HANDLING-FEE', 'RECONSIGNMENT-FEE', 'REDELIVERY-FEE', 'REMOTE-SHIPPING', 'SHIPPING-FOR-COM', 'STORAGE-FEE', 'WAREHOUSE-HOLD', 'WGS001', 'EXPEDITE-FEE'
      )
      @ca_overview = ShippingDetail.where('extract(year from shipping_details.created_at) = ?', @year).joins(:order).where(orders: { store: 'canada', status: 'completed' }).eager_load(:line_items).where.not(
        '(line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?)', 'CUSTOMIZATION-FEE', 'E-PMNT', 'HANDLING-FEE', 'RECONSIGNMENT-FEE', 'REDELIVERY-FEE', 'REMOTE-SHIPPING', 'SHIPPING-FOR-COM', 'STORAGE-FEE', 'WAREHOUSE-HOLD', 'WGS001', 'EXPEDITE-FEE'
      )
    else
      @us_overview = ShippingDetail.joins(:order).where(orders: { store: 'us', status: 'completed' }).eager_load(:line_items).where.not(
        '(line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?)', 'CUSTOMIZATION-FEE', 'E-PMNT', 'HANDLING-FEE', 'RECONSIGNMENT-FEE', 'REDELIVERY-FEE', 'REMOTE-SHIPPING', 'SHIPPING-FOR-COM', 'STORAGE-FEE', 'WAREHOUSE-HOLD', 'WGS001', 'EXPEDITE-FEE'
      )
      @ca_overview = ShippingDetail.joins(:order).where(orders: { store: 'canada', status: 'completed' }).eager_load(:line_items).where.not(
        '(line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?) OR (line_items.sku = ?)', 'CUSTOMIZATION-FEE', 'E-PMNT', 'HANDLING-FEE', 'RECONSIGNMENT-FEE', 'REDELIVERY-FEE', 'REMOTE-SHIPPING', 'SHIPPING-FOR-COM', 'STORAGE-FEE', 'WAREHOUSE-HOLD', 'WGS001', 'EXPEDITE-FEE'
      )
    end

    @state = params[:state]
    if @state.present?
      case @state
      when 'alabama'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'alabama', 'al'
        )
        @ca_shipping_details = @ca_overview
      when 'alaska'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'alaska', 'ak'
        )
        @ca_shipping_details = @ca_overview
      when 'american_samoa'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'american samoa', 'as'
        )
        @ca_shipping_details = @ca_overview
      when 'arizona'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'arizona', 'az'
        )
        @ca_shipping_details = @ca_overview
      when 'arkansas'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'arkansas', 'ar'
        )
        @ca_shipping_details = @ca_overview
      when 'california'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'california', 'ca'
        )
        @ca_shipping_details = @ca_overview
      when 'colorado'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'colorado', 'co'
        )
        @ca_shipping_details = @ca_overview
      when 'connecticut'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'connecticut', 'ct'
        )
        @ca_shipping_details = @ca_overview
      when 'delaware'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'delaware', 'de'
        )
        @ca_shipping_details = @ca_overview
      when 'district_of_columbia'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'district of columbia', 'dc'
        )
        @ca_shipping_details = @ca_overview
      when 'florida'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'florida', 'fl'
        )
        @ca_shipping_details = @ca_overview
      when 'georgia'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'georgia', 'ga'
        )
        @ca_shipping_details = @ca_overview
      when 'guam'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'guam', 'gu'
        )
        @ca_shipping_details = @ca_overview
      when 'hawaii'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'hawaii', 'hi'
        )
        @ca_shipping_details = @ca_overview
      when 'idaho'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'idaho', 'id'
        )
        @ca_shipping_details = @ca_overview
      when 'illinois'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'illinois', 'il'
        )
        @ca_shipping_details = @ca_overview
      when 'indiana'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'indiana', 'in'
        )
        @ca_shipping_details = @ca_overview
      when 'iowa'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'iowa', 'ia'
        )
        @ca_shipping_details = @ca_overview
      when 'kansas'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'kansas', 'ks'
        )
        @ca_shipping_details = @ca_overview
      when 'kentucky'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'kentucky', 'ky'
        )
        @ca_shipping_details = @ca_overview
      when 'louisiana'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'louisiana', 'la'
        )
        @ca_shipping_details = @ca_overview
      when 'maine'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'maine', 'me'
        )
        @ca_shipping_details = @ca_overview
      when 'maryland'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'maryland', 'md'
        )
        @ca_shipping_details = @ca_overview
      when 'massachusetts'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'massachusetts', 'ma'
        )
        @ca_shipping_details = @ca_overview
      when 'michigan'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'michigan', 'mi'
        )
        @ca_shipping_details = @ca_overview
      when 'minnesota'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'minnesota', 'mn'
        )
        @ca_shipping_details = @ca_overview
      when 'mississippi'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'mississippi', 'ms'
        )
        @ca_shipping_details = @ca_overview
      when 'missouri'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'missouri', 'mo'
        )
        @ca_shipping_details = @ca_overview
      when 'montana'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'montana', 'mt'
        )
        @ca_shipping_details = @ca_overview
      when 'nebraska'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'nebraska', 'ne'
        )
        @ca_shipping_details = @ca_overview
      when 'nevada'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'nevada', 'nv'
        )
        @ca_shipping_details = @ca_overview
      when 'new_hampshire'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'new hampshire', 'nh'
        )
        @ca_shipping_details = @ca_overview
      when 'new_jersey'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'new jersey', 'nj'
        )
        @ca_shipping_details = @ca_overview
      when 'new_mexico'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'new mexico', 'nm'
        )
        @ca_shipping_details = @ca_overview
      when 'new_york'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'new york', 'ny'
        )
        @ca_shipping_details = @ca_overview
      when 'north_carolina'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'north carolina', 'nc'
        )
        @ca_shipping_details = @ca_overview
      when 'north_dakota'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'north dakota', 'nd'
        )
        @ca_shipping_details = @ca_overview
      when 'northern_mariana_islands'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'northern mariana islands', 'mp'
        )
        @ca_shipping_details = @ca_overview
      when 'ohio'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'ohio', 'oh'
        )
        @ca_shipping_details = @ca_overview
      when 'oklahoma'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'oklahoma', 'ok'
        )
        @ca_shipping_details = @ca_overview
      when 'oregon'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'oregon', 'or'
        )
        @ca_shipping_details = @ca_overview
      when 'pennsylvania'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'pennsylvania', 'pa'
        )
        @ca_shipping_details = @ca_overview
      when 'puerto_rico'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'puerto rico', 'pr'
        )
        @ca_shipping_details = @ca_overview
      when 'rhode_island'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'rhode island', 'ri'
        )
        @ca_shipping_details = @ca_overview
      when 'south_carolina'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'south carolina', 'sc'
        )
        @ca_shipping_details = @ca_overview
      when 'south_dakota'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'south dakota', 'sd'
        )
        @ca_shipping_details = @ca_overview
      when 'tennessee'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'tennessee', 'tn'
        )
        @ca_shipping_details = @ca_overview
      when 'texas'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'texas', 'tx'
        )
        @ca_shipping_details = @ca_overview
      when 'us_virgin_islands'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'u.s. virgin islands', 'vi'
        )
        @ca_shipping_details = @ca_overview
      when 'utah'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'utah', 'ut'
        )
        @ca_shipping_details = @ca_overview
      when 'vermont'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'vermont', 'vt'
        )
        @ca_shipping_details = @ca_overview
      when 'virginia'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'virginia', 'va'
        )
        @ca_shipping_details = @ca_overview
      when 'washington'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'washington', 'wa'
        )
        @ca_shipping_details = @ca_overview
      when 'west_virginia'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'west virginia', 'wv'
        )
        @ca_shipping_details = @ca_overview
      when 'wisconsin'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'wisconsin', 'wi'
        )
        @ca_shipping_details = @ca_overview
      when 'wyoming'
        @us_shipping_details = @us_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'wyoming', 'wy'
        )
        @ca_shipping_details = @ca_overview
      when 'alberta'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'alberta', 'ab'
        )
      when 'british_columbia'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'british columbia', 'bc'
        )
      when 'manitoba'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'manitoba', 'mb'
        )
      when 'new_brunswick'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'new brunswick', 'nb'
        )
      when 'newfoundland_and_labrador'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'newfoundland and labrador', 'nl'
        )
      when 'northwest_territories'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'northwest territories', 'nt'
        )
      when 'nova_scotia'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'nova scotia', 'ns'
        )
      when 'nunavut'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'nunavut', 'nu'
        )
      when 'ontario'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'ontario', 'on'
        )
      when 'prince_edward_island'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'prince edward island', 'pe'
        )
      when 'quebec'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'quebec', 'qc'
        )
      when 'saskatchewan'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'saskatchewan', 'sk'
        )
      when 'yukon'
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview.joins(order: :shipping_address).where(
          'lower(shipping_addresses.address2) = ? OR lower(shipping_addresses.address2) = ?', 'yukon', 'yt'
        )
      else
        @us_shipping_details = @us_overview
        @ca_shipping_details = @ca_overview
      end
    else
      @us_shipping_details = @us_overview
      @ca_shipping_details = @ca_overview
    end

    @us_curb = @us_shipping_details.where(shipping_details: { white_glove_fee: [nil, ''] })
    @us_wgs = @us_shipping_details.where.not(shipping_details: { white_glove_fee: [nil, ''] })

    @ca_curb = @ca_shipping_details.where(shipping_details: { white_glove_fee: [nil, ''] })
    @ca_wgs = @ca_shipping_details.where.not(shipping_details: { white_glove_fee: [nil, ''] })

    @store = params[:currency]

    if @store == 'us'
      @currency = 'USD'
      @exchange_rate = if StoreAddress.find_by(store: 'us').exchange_rate.present?
                          StoreAddress.find_by(store: 'us').exchange_rate
                        else
                          1
                        end
    else
      @currency = 'CAD'
      @exchange_rate = if StoreAddress.find_by(store: 'canada').exchange_rate.present?
                          StoreAddress.find_by(store: 'canada').exchange_rate
                        else
                          1
                        end
    end
  end

  def report_orders
    @orders_current_year = Order.set_store(current_store).eager_load(:shipping_line, :line_items, :order_adjustments).where(
      'extract(year from orders.created_at) = ?', Date.today.year
    )
    @orders_previous_year = Order.set_store(current_store).eager_load(:shipping_line, :line_items, :order_adjustments).where(
      'extract(year from orders.created_at) = ?', Date.today.year - 1
    )
    @orders_today = Order.set_store(current_store).eager_load(:shipping_line, :line_items, :order_adjustments).where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    @orders_yesterday = Order.set_store(current_store).eager_load(:shipping_line, :line_items, :order_adjustments).where(created_at: (Time.zone.now - 1.day).beginning_of_day..(Time.zone.now - 1.day).end_of_day)

    respond_to do |format|
      format.html do
        case params[:b].to_i
        when 0
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today.at_beginning_of_week, Date.today.at_end_of_week)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)',Date.today.at_beginning_of_week, Date.today.at_end_of_week)
        when 1
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today.at_beginning_of_month, Date.today.at_end_of_month)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)',Date.today.at_beginning_of_month, Date.today.at_end_of_month)
        when 2
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today - 90.days, Date.today)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today - 90.days, Date.today)
        end
        case params[:c]
        when 'this_month'
          default_count = {}
          for i in 1..Date.today.at_end_of_month.day do
            default_count.store(Date.new(Date.today.year, Date.today.month, i).strftime("%d %^b, %Y"), 0)
          end
          orders = @orders_current_year.where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today.at_beginning_of_month, Date.today.at_end_of_month)
          series = [*1..Date.today.day]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_day(:created_at, format: "%d %^b, %Y").count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(day from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when '90_days'
          default_count = {}
          for i in 0..89 do
            default_count.store(Date.today.days_ago(90 - i).strftime("%d %^b, %Y"), 0)
          end
          orders = @orders_current_year.where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today - 90.days, Date.today)
          series = [*1..90]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_day(:created_at, format: "%d %^b, %Y").count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(day from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when 'current'
          default_count = { 'JAN' => 0, 'FEB' => 0, 'MAR' => 0, 'APR' => 0, 'MAY' => 0, 'JUN' => 0, 'JUL' => 0, 'AUG' => 0,
          'SEP' => 0, 'OCT' => 0, 'NOV' => 0, 'DEC' => 0 }
          orders = @orders_current_year
          series = [*1..12]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_month(:created_at, format: '%^b').count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(month from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when 'previous'
          default_count = { 'JAN' => 0, 'FEB' => 0, 'MAR' => 0, 'APR' => 0, 'MAY' => 0, 'JUN' => 0, 'JUL' => 0, 'AUG' => 0,
          'SEP' => 0, 'OCT' => 0, 'NOV' => 0, 'DEC' => 0 }
          orders = @orders_previous_year
          series = [*1..12]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_month(:created_at, format: '%^b').count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(month from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        end
      end
      format.js do
        case params[:c]
        when 'this_month'
          default_count = {}
          for i in 1..Date.today.at_end_of_month.day do
            default_count.store(Date.new(Date.today.year, Date.today.month, i).strftime("%d %^b, %Y"), 0)
          end
          orders = @orders_current_year.where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today.at_beginning_of_month, Date.today.at_end_of_month)
          series = [*1..Date.today.day]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_day(:created_at, format: "%d %^b, %Y").count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(day from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when '90_days'
          default_count = {}
          for i in 0..89 do
            default_count.store(Date.today.days_ago(90 - i).strftime("%d %^b, %Y"), 0)
          end
          orders = @orders_current_year.where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today - 90.days, Date.today)
          series = [*1..90]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_day(:created_at, format: "%d %^b, %Y").count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(day from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when 'current'
          default_count = { 'JAN' => 0, 'FEB' => 0, 'MAR' => 0, 'APR' => 0, 'MAY' => 0, 'JUN' => 0, 'JUL' => 0, 'AUG' => 0,
          'SEP' => 0, 'OCT' => 0, 'NOV' => 0, 'DEC' => 0 }
          orders = @orders_current_year
          series = [*1..12]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_month(:created_at, format: '%^b').count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(month from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        when 'previous'
          default_count = { 'JAN' => 0, 'FEB' => 0, 'MAR' => 0, 'APR' => 0, 'MAY' => 0, 'JUN' => 0, 'JUL' => 0, 'AUG' => 0,
          'SEP' => 0, 'OCT' => 0, 'NOV' => 0, 'DEC' => 0 }
          orders = @orders_previous_year
          series = [*1..12]
          @d1 = default_count.clone
          @d2 = default_count.clone
      
          if orders.present?
            @d1 = @d1.merge(orders.group_by_month(:created_at, format: '%^b').count)
            series.each do |i|
              @d2[@d2.keys[series.index(i)]] = orders.where('extract(month from orders.created_at) = ?', i).sum do |order|
                order&.line_items&.sum do |s|
                  mul(s&.price, s&.quantity)
                end - (order&.discount_codes.present? ? order&.discount_codes['discount_amount']&.to_f&.abs : 0) + order&.shipping_line&.price.to_f + (order&.tax_lines.present? ? order&.tax_lines['price']&.to_f : 0) + order&.order_adjustments&.sum do |s|
                                                                                                                                                                                                                            s&.amount&.to_f
                                                                                                                                                                                                                          end
              end
            end
          end
        end
      end
    end
  end

  def bestseller_skus
    respond_to do |format|
      format.js do
        case params[:b].to_i
        when 0
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today.at_beginning_of_week, Date.today.at_end_of_week)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)',Date.today.at_beginning_of_week, Date.today.at_end_of_week)
        when 1
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today.at_beginning_of_month, Date.today.at_end_of_month)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)',Date.today.at_beginning_of_month, Date.today.at_end_of_month)
        when 2
          @items = LineItem.set_store(current_store).non_swatches.eager_load(:order).joins(:order).where(
            '(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001'
          ).where('(orders.created_at > ?) and (orders.created_at < ?)',
                                                                    Date.today - 90.days, Date.today)
          @swatch_items = LineItem.set_store(current_store).swatches.eager_load(:order).joins(:order).where('(orders.created_at > ?) and (orders.created_at < ?)', Date.today - 90.days, Date.today)
        end
      end
    end
  end

  def report_logistics_export
    case params[:report_type]
    when 'shipment'
      @shipping_details = ShippingDetail.eager_load(:line_items, order: %i[line_items order_adjustments shipping_address shipping_line customer shipping_details]).joins(:line_items, :order).where('(line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (orders.store ILIKE ?) or (line_items.order_from ILIKE ?)', '%warranty%', 'WGS001', 'HLD001', 'HFE001', current_store, nil)

      if params[:start_date].present?
        @shipping_details = @shipping_details.where("orders.created_at > ?", params[:start_date])
      end

      if params[:end_date].present?
        @shipping_details = @shipping_details.where("orders.created_at < ?", params[:end_date])
      end

    when 'order'
      @orders = Order.set_store(current_store).eager_load(:customer, :shipping_details, :shipping_line, :shipping_address)

      if params[:start_date].present?
        if params[:status] == "5"
          @orders = @orders.where("shipping_details.shipped_date > ?", Time.zone.parse(params[:start_date]))
        else
          @orders = @orders.where("orders.created_at > ?", Time.zone.parse(params[:start_date]))
        end
      end

      if params[:end_date].present?
        if params[:status] == "5"
          @orders = @orders.where("shipping_details.shipped_date < ?", Time.zone.parse(params[:end_date]))
        else
          @orders = @orders.where("orders.created_at < ?",  Time.zone.parse(params[:end_date]))
        end
      end

      if params[:state].present?
        @orders = @orders.where("shipping_addresses.address2 ILIKE ANY (array[?])", params[:state].split(",").uniq)
      end

      if params[:status].present?
        if params[:status] == "20"
          @orders = @orders.where("orders.status = ?", 9).order("shipping_details.shipped_date DESC")
        else
          @orders = @orders.where("shipping_details.status = ?", params[:status].to_i).order("shipping_details.shipped_date DESC")
        end
      end

      @orders = @orders.where.not(order_type: 'SW')
    when 'email_order'
      @line_items = LineItem.set_store(current_store).non_swatches.where('(title NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?) and (sku NOT LIKE ?)', 'Default Title', '%warranty%', 'WGS001', 'HLD001', 'HFE001', 'Replacement-Parts')

      if params[:start_date].present?
        @line_items = @line_items.where("line_items.created_at > ?", params[:start_date])
      end

      if params[:end_date].present?
        @line_items = @line_items.where("line_items.created_at < ?", params[:end_date])
      end

    when 'claim_order'
      @issues = Issue.eager_load(order: [:customer]).joins(:order).where(orders: { store: current_store }).where.not(status: 'closed').where(
        '(issues.created_at > ?) and (issues.created_at < ?)', params[:start_date], params[:end_date])
    when 'purchase_order'
      @purchases = Purchase.set_store(current_store).where('(purchases.created_at > ?) and (purchases.created_at < ?)', params[:start_date], params[:end_date])
    end
  end

  def export_order
    @orders = Order.where(store: current_store).where.not(status: [:cancel_confirmed, :completed])
  end

  def create_shipment
    order = Order.find_by(id: params[:order_id])
    if params[:order_id].present? && params[:ship_id].present?
      order = Order.find_by(id: params[:order_id])
      shipping_detail = ShippingDetail.find_by(id: params[:ship_id])
      if shipping_detail.tracking_url_for_ship.present? && (shipping_detail.status == 'shipped')
        Magento::UpdateOrder.new(order.store).create_shipment(order,
                                                              shipping_detail)
      end
    end
    redirect_to edit_admin_order_path(order)
  end

  def create_replacement_order
    order = Order.find_by(id: params[:order_id])
    issue = Issue.find_by(id: params[:issue_id])
    new_order = order.dup
    i = 1
    while Order.find_by(name: "R" + i.to_s.rjust(2, "0") + "-" + order.name).present? do
      i += 1
    end
    new_order.update(name: "R" + i.to_s.rjust(2, "0") + "-" + order.name, status: "in_progress", discount_codes: nil, tax_lines: nil)
    new_order.billing_address = order.billing_address.dup
    new_order.shipping_address = order.shipping_address.dup

    if new_order.save
      issue.update(order_link: issue.order_link.to_s + "," + new_order.id.to_s)
      new_order.update(eta: new_order.kind_of_order == "QS" ? new_order.created_at.to_date + 7.days : new_order.created_at.to_date + 112.days)
      
      order_list = []
      order_list.push(new_order.id)
      order_list.push(order.id)
      order_list.push(order.order_link)
      order_list = order_list.flatten.compact.uniq  
      order_list.each do |o|
        Order.find_by(id: o).update(order_link: order_list)
      end

      sd = new_order.shipping_details.create(status: "not_ready")
      
      if issue.shipping_curbside.present?
        carrier = Carrier.find_by(name: issue.shipping_curbside, country: new_order.store)
        if carrier.present?
          sd.update(carrier_id: carrier.id)
          sd.shipping_quotes.create(carrier_id: carrier.id, truck_broker_id: carrier.truck_broker.id, selected: true)
        end
      end
      if issue.shipping_wgd.present?
        sd.update(white_glove_delivery: true)
        wgd = WhiteGloveAddress.find_by(company: issue.shipping_wgd)
        if wgd.present?
          sd.update(white_glove_address_id: wgd.id)
        else
          w = WhiteGloveAddress.create(company: issue.shipping_wgd)
          sd.update(white_glove_address_id: w.id)
        end
      end

      if params[:variant_items].present? && params[:variant_quantities].present?
        line_items = params[:variant_items][1..-1].split(",")
        line_quantities = params[:variant_quantities][1..-1].split(",")
        line_items.each_with_index do |item, i|
          variant = ProductVariant.find_by(id: item)
          variant.update(old_inventory_quantity: variant&.inventory_quantity.to_i, inventory_quantity: variant&.inventory_quantity.to_i - line_quantities[i].to_i, to_do_quantity: variant&.to_do_quantity.to_i + line_quantities[i].to_i)
          InventoryHistory.create(product_variant_id: variant.id, event: "Order Created (#{new_order.name})", adjustment: -line_quantities[i].to_i, quantity: variant.inventory_quantity)

          if variant.inventory_quantity < 0
            new_order.line_items.create(product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity.to_i, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: variant&.price, quantity: line_quantities[i].to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: variant&.title.to_s, name: variant&.title.to_s, shipping_detail_id: sd.id, store: new_order.store, status: "not_started")
          else
            new_order.line_items.create(product_id: variant&.product_id, variant_id: variant&.id, shopify_line_item_id: variant&.shopify_variant_id, fulfillable_quantity: variant&.inventory_quantity.to_i, fulfillment_service: variant&.fulfillment_service, grams: variant&.grams, price: variant&.price, quantity: line_quantities[i].to_i, requires_shipping: variant&.requires_shipping, sku: variant&.sku, title: variant&.title.to_s, name: variant&.title.to_s, shipping_detail_id: sd.id, store: new_order.store, status: "ready")
          end
        end
      end
      if params[:reference_items].present? && params[:reference_quantities].present?
        reference_items = params[:reference_items][1..-1].split(",")
        reference_quantities = params[:reference_quantities][1..-1].split(",")
        reference_items.each_with_index do |item, i|
          reference = ReplacementReference.find_by(id: item)
          variant = reference.product_variant
          variant.update(old_inventory_quantity: variant&.inventory_quantity.to_i, inventory_quantity: variant&.inventory_quantity.to_i - reference_quantities[i].to_i, to_do_quantity: variant&.to_do_quantity.to_i + reference_quantities[i].to_i)
          InventoryHistory.create(product_variant_id: variant.id, event: "Order Created (#{new_order.name})", adjustment: -reference_quantities[i].to_i, quantity: variant.inventory_quantity)

          if variant.inventory_quantity < 0
            new_order.line_items.create(variant_id: variant&.id, fulfillable_quantity: variant&.inventory_quantity.to_i, quantity: reference_quantities[i].to_i, sku: reference.name, title: variant&.title, name: variant&.title, shipping_detail_id: sd.id, store: new_order.store, status: "not_started", replacement_reference_id: reference.id)
          else
            new_order.line_items.create(variant_id: variant&.id, fulfillable_quantity: variant&.inventory_quantity.to_i, quantity: reference_quantities[i].to_i, sku: reference.name, title: variant&.title, name: variant&.title, shipping_detail_id: sd.id, store: new_order.store, status: "ready", replacement_reference_id: reference.id)
          end
        end
      end
      redirect_to edit_admin_order_path(new_order)
    else
      flash[:alert] = "Replacement order failed to be created. Please contact admin."
      redirect_to edit_admin_issue_path(issue)
    end
  end

  def orders_per_date
    @orders = Order.where("orders.created_at > ? AND orders.created_at < ?",params[:start_date],params[:end_date])
    count = @orders.count
    order_data = @orders.pluck(:shopify_order_id,:name)
    render json: { count: count, orders: order_data }
  end

  private

  def find_line_item
    @line_item = LineItem.find_by(order_id: @order.id)
  end

  def find_order
    # order_sync = ShopifyManager::OrderSync.new(current_store)
    @order = Order.eager_load(:customer,
                              shipping_details: [:pallet_shippings,
                                                  { files_attachments: [:blob] }]).find_by(name: params[:name])
    # order_sync.get_order(@order.shopify_order_id)
    @order
  end

  def order_params
    params.require(:order).permit(:id, :order_id, :status, :shopify_order_id, :contact_email, :name, :customer_id, :hold_until_date, :hold_reason, :cancel_reason, :order_notes, files: [], shipping_details_attributes: [ :eta_from, :eta_to, :pickup_start_date, :additional_charges, :additional_fees, :upgrade,:actual_invoiced, :white_glove_fee, :local_white_glove_delivery, :local_pickup, :remote, :overhang, :tracking_number, :printed_bol, :printed_packing_slip, :local_delivery, :estimated_shipping_cost, :date_booked, :hold_until_date, :status, :white_glove_delivery, :shipping_notes,  :carrier_id, :_destroy, :id, { files: [], white_glove_address_attributes: %i[id contact company address1 address2 city country zip phone email notes delivery_notification receiving_hours], pallet_shippings_attributes: %i[height length width weight auto_calc _destroy id pallet_id order_id], shipping_costs_attributes: %i[id cost_type name amount] }], line_items_attributes: %i[pallet_shipping_id order_from id order_id shipping_detail_id status cancel_quantity], discount_codes: [], tax_lines: [], shipping_address_attributes: %i[first_name last_name company address1 address2 city country zip phone email])
  end
end
