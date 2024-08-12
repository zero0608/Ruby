class Admin::ContainersController < ApplicationController
  include Pagy::Backend
  require 'pagy/extras/items'
  before_action :find_container, only: [:edit, :update]

  def index
    if current_user.user_group.inventory_view && current_user.user_group.permission_us
      if params[:container_status].present?
        @containers ||= Container.where(store: "us", status: params[:container_status].to_s)
      else
        @pagy, @containers = pagy(Container.where(store: "us"), items_param: :per_page, max_items: 100)
      end
      params[:time] = params[:time].split("?")[0] if (params[:time].include? '?')
      if params[:time] == "this_week"
        @arriving_label ||= "This Week"
        @arriving_date_begin ||= Time.now.at_beginning_of_week
        @arriving_date_end ||= Time.now.at_end_of_week
      elsif params[:time] == "next_week"
        @arriving_label ||= "Next Week"
        @arriving_date_begin ||= Time.now.next_day(7).at_beginning_of_week
        @arriving_date_end ||= Time.now.next_day(7).at_end_of_week
      elsif params[:time] == "this_month"
        @arriving_label ||= "This Month"
        @arriving_date_begin ||= Time.now.at_beginning_of_month
        @arriving_date_end ||= Time.now.at_end_of_month
      end
      @containers_arriving = Container.where(store: "us").where.not(status: :arrived).where(arriving_to_dc: (@arriving_date_begin)..(@arriving_date_end)).order(:arriving_to_dc)
    else
      render "dashboard/unauthorized"
    end
  end

  def emca_container_index
    if current_user.user_group.inventory_view && current_user.user_group.permission_ca
      if params[:container_status].present?
        @containers ||= Container.where(store: "canada", status: params[:container_status].to_s)
      else
        @pagy, @containers = pagy(Container.where(store: "canada"), items_param: :per_page, max_items: 100)
      end
      params[:time] = params[:time].split("?")[0] if (params[:time].include? '?')
      if params[:time] == "this_week"
        @arriving_label ||= "This Week"
        @arriving_date_begin ||= Time.now.at_beginning_of_week
        @arriving_date_end ||= Time.now.at_end_of_week
      elsif params[:time] == "next_week"
        @arriving_label ||= "Next Week"
        @arriving_date_begin ||= Time.now.next_day(7).at_beginning_of_week
        @arriving_date_end ||= Time.now.next_day(7).at_end_of_week
      elsif params[:time] == "this_month"
        @arriving_label ||= "This Month"
        @arriving_date_begin ||= Time.now.at_beginning_of_month
        @arriving_date_end ||= Time.now.at_end_of_month
      end
      @containers_arriving = Container.where(store: "canada").where.not(status: :arrived).where(arriving_to_dc: (@arriving_date_begin)..(@arriving_date_end)).order(:arriving_to_dc)
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    if current_user.user_group.inventory_cru && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      @container = Container.new
      @container.container_purchases.build
      @purchase_items = PurchaseItem.eager_load(:purchase).joins(:purchase).where(status: :container_ready, purchases: { store: current_store })
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    ::Audited.store[:current_user] = current_user
    @container =  Container.new container_params
    if params[:purchase_item_ids].present? && @container.save
      ContainerWorkerWorker.perform_async(@container.id,params[:purchase_item_ids])
      if @container.container_charges.empty?
        @container.container_charges.create([{ charge: "Container" }, { charge: "Brokerage" }, { charge: "Duties" }, { charge: "Drayage" }, { charge: "Demurrage" }])
      end

      @container.purchase_items.where.not(status: :cancelled).where(order_id: nil).map { |item| item.update(preorder_quantity: item.quantity) }

      if current_store == 'us'
        redirect_to admin_containers_path(container_status: "en_route", time: "this_week")
      else
        redirect_to emca_container_index_admin_containers_path(container_status: "en_route", time: "this_week")
      end
      Magento::UpdateOrder.new(current_store).update_container(@container)
    else
      redirect_to new_admin_container_path, warning: "Container failed to be created."
    end
  end

  def edit
    ::Audited.store[:current_user] = current_user
    @purchase_items = PurchaseItem.eager_load(:purchase).joins(:purchase).where(status: :container_ready, purchases: { store: current_store })
    if current_user.user_group.inventory_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      if params[:ret].present? && params[:ret] == 'container_add_to_inventory' && params[:purchase_item_id].present?
        @line_item = LineItem.find(params[:line_item_id])
        @purchase_item = PurchaseItem.find(params[:purchase_item_id])
        @purchase_item.update(line_item_id: nil)
        @purchase_item.purchase.store == 'us' ? @purchase_item.update(purchase_type: 'CTUS') : @purchase_item.update(purchase_type: 'CTCA')
        
        Magento::UpdateOrder.new(@line_item.try(:variant).store).update_quantity(@line_item.try(:variant))
        Magento::UpdateOrder.new(@line_item.try(:variant).store).update_arriving_case_1_3(@line_item.try(:variant))
        redirect_to edit_admin_container_path
      end
      if @container.container_charges.empty?
        @container.container_charges.create([{ charge: "Container" }, { charge: "Brokerage" }, { charge: "Duties" }, { charge: "Drayage" }, { charge: "Demurrage" }])
      end
      # if @container.container_costs.empty?
      #   if @container.store == "us"
      #     @container.container_costs.create({ carrier_type: "ocean", name: "Duties"})
      #   else
      #     @container.container_costs.create({ carrier_type: "ocean", name: "GST"})
      #   end
      #   @container.container_costs.create([{ carrier_type: "ocean", name: "Local Handling" }, { carrier_type: "ocean", name: "Customs Brokerage" }, { carrier_type: "ocean", name: "Demurrage Fee" }, { carrier_type: "ocean" }, { carrier_type: "drayage" }])
      # end
      # Magento::UpdateOrder.new(current_store).update_container(@container)
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    ::Audited.store[:current_user] = current_user
    if params[:assign_orders].present? && params[:assign_orders][:ids].present?
      @container = Container.find(params[:id])
      @purchase_item = PurchaseItem.find(params[:purchase_item_id])
      params[:assign_orders][:ids].each do |id|
        @line_item = LineItem.find(id)
        if @purchase_item.quantity.to_i >= @line_item.quantity.to_i
          @purchase_item.update(quantity: (@purchase_item.quantity.to_i - @line_item.quantity.to_i))
          @line_item.update(status: "en_route", container_id: @container.id, purchase_item_id: @purchase_item.id, purchase_id: @purchase_item.purchase_id)
        end
        Magento::UpdateOrder.new(@line_item.try(:variant).store).update_arriving_case_1_3(@line_item.try(:variant))
      end
    elsif params[:purchase_item_ids].present?
      @container = Container.find(params[:id])
      params[:purchase_item_ids].each do |id|
        unless @container.purchase_items.where(id: id).present?
          @container_purchase = @container.container_purchases.build
          @container_purchase.purchase_item_id = id
          @container_purchase.save
          @container_purchase.purchase_item.update(status: :completed)
          PurchaseItem.find(id).line_item.update(status: :container_ready) if PurchaseItem.find(id).line_item.present?
          LineItem.where(purchase_item_id: id, purchase_id: PurchaseItem.find(id).purchase_id).update_all(container_id: @container.id) if LineItem.where(purchase_item_id: id, purchase_id: PurchaseItem.find(id).purchase_id).present?
          Magento::UpdateOrder.new(@container.store).update_arriving_case_1_3(PurchaseItem.find(id).product_variant) if PurchaseItem.find(id).product_variant_id.present? && !(PurchaseItem.find(id).line_item_id.present?)
        end
      end
      if @container.container_charges.empty?
        @container.container_charges.create([{ charge: "Container" }, { charge: "Brokerage" }, { charge: "Duties" }, { charge: "Drayage" }, { charge: "Demurrage" }])
      end
    end
    redirect_to edit_admin_container_path
  end

  def arriving
    if current_user.user_group.dc_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      ::Audited.store[:current_user] = current_user

      #containers arriving
      @con_label ||= "This Week"
      @con_date_begin ||= Time.now.at_beginning_of_week
      @con_date_end ||= Time.now.at_end_of_week
      @con_arriving = Container.where(store: current_store).where.not(status: :arrived).where(arriving_to_dc: (@con_date_begin)..(@con_date_end))
      
      @containers = Container.where(store: current_store).where.not(status: :arrived).order(:arriving_to_dc)
      if params[:container_id].present?
        @container = Container.find(params[:container_id])
        unless @container.status == "arrived"
          @container.update(received_date: Date.current)
          @container.update(status: :arrived)
          Magento::UpdateOrder.new(current_store).enabled_container(@container)

          UserNotification.with(order: 'nil', issue: 'nil', user: current_user, content: 'arrived', container: @container).deliver(User.where(deactivate: [false, nil]).where("notification_setting->>'arriving_container' = ?", '1'))

          @a = @b = 0
          @container.purchase_items.each do |item|
            if item.product_variant.present? && !(item.line_item.present?)
              @variant = ProductVariant.find_by(id: item.product_variant_id)
              @variant.line_items.joins(:order).where(status: 'en_route', container_id: @container.id, orders: { store: current_store }).update_all(status: 'ready') if (@variant.line_items.joins(:order).where(status: 'en_route', container_id: @container.id, orders: { store: current_store }).present?)
              @container.line_items.where.not(status: :cancelled).update_all(status: 'ready') if @container.line_items.present?
              if @container.line_items.present?
                @container.line_items.each do |line_item|
                  order = line_item.order
                  @product_variant = ProductVariant.find_by(id: line_item.variant_id)

                  @product_variant.update(container_count: (@product_variant.container_count.to_i + line_item.quantity.to_i))

                  ContainerOrder.create(product_variant_id: @product_variant.id, order_id: line_item.order.id, line_item_id: line_item.id, name: line_item.order.name, quantity: line_item.quantity)
                  Magento::UpdateOrder.new(order.store).update_status("#{order.shopify_order_id}", "#{order.status}")
                end
              end
              ProductVariant.find_by(id: item.product_variant_id).update(inventory_quantity: (ProductVariant.find_by(id: item.product_variant_id).inventory_quantity.to_i + item.quantity.to_i))
              if ProductVariant.find_by(id: item.product_variant_id).cartons.present?
                ProductVariant.find_by(id: item.product_variant_id).update(received_quantity: (ProductVariant.find_by(id: item.product_variant_id).received_quantity.to_i + item.preorder_quantity.to_i))
                ProductVariant.find_by(id: item.product_variant_id).cartons.each do |carton|
                  carton.update(received_quantity: (carton.received_quantity.to_i + item.preorder_quantity.to_i))
                end
              else
                ProductVariant.find_by(id: item.product_variant_id).update(received_quantity: (ProductVariant.find_by(id: item.product_variant_id).received_quantity.to_i + item.preorder_quantity.to_i))
              end
              if @container.warehouse_id.present?
                if WarehouseVariant.where(warehouse_id: @container.warehouse_id, product_variant_id: item.product_variant_id).present?
                  @warehouse = WarehouseVariant.where(warehouse_id: @container.warehouse_id, product_variant_id: item.product_variant_id).first
                  WarehouseVariant.where(warehouse_id: @container.warehouse_id, product_variant_id: item.product_variant_id).first.update(warehouse_quantity: @warehouse.warehouse_quantity.to_i + item.quantity.to_i)
                else
                  WarehouseVariant.create(warehouse_id: @container.warehouse_id, product_variant_id: item.product_variant_id, warehouse_quantity: item.quantity.to_i, store: current_store)
                end
              end
              if @container.warehouse_id.present?
                InventoryHistory.create(product_variant_id: item.product_variant_id, user_id: current_user.id, container_id: @container.id, event: "container inventory arrived to #{@container.warehouse.name} of quantity #{item.quantity}", adjustment: item.quantity.to_i, quantity:  ProductVariant.find_by(id: item.product_variant_id).inventory_quantity.to_i, warehouse_id: @container.warehouse_id, warehouse_adjustment: item.quantity.to_i, warehouse_quantity: WarehouseVariant.where(warehouse_id: @container.warehouse_id, product_variant_id: item.product_variant_id).first.warehouse_quantity)
              else
                InventoryHistory.create(product_variant_id: item.product_variant_id, user_id: current_user.id, container_id: @container.id, event: "Container Arrived ", adjustment: item.quantity.to_i, quantity:  ProductVariant.find_by(id: item.product_variant_id).inventory_quantity.to_i)
              end
            else
              if item.line_item.present? && item.line_item.variant.present?
                if item.line_item.order.status == 'cancel_confirmed'
                  line_item = LineItem.find_by(id: item.line_item_id)
                  new_qty = ProductVariant.find_by(id: line_item.variant_id).inventory_quantity.to_i + line_item.quantity.to_i
                  ProductVariant.find_by(id: line_item.variant_id).update(inventory_quantity: new_qty)
                  InventoryHistory.create(product_variant_id: item.product_variant_id, user_id: current_user.id, container_id: @container.id, event: "Container Arrived(#{line_item.order.name})", adjustment: line_item.quantity.to_i, quantity:  ProductVariant.find_by(id: item.product_variant_id).inventory_quantity.to_i) if item.product_variant_id.present? && ProductVariant.find_by(id: item.product_variant_id).inventory_histories.present?
                  line_item.update(status: :cancelled)
                else
                  line_item = LineItem.find_by(id: item.line_item_id)
                  item.line_item.update(status: :ready)
                  @product_variant = ProductVariant.find_by(id: item.product_variant_id)

                  ProductVariant.find_by(id: item.product_variant_id).update(container_count: (@product_variant.container_count.to_i + line_item.quantity.to_i))

                  ContainerOrder.create(product_variant_id: @product_variant.id, order_id: line_item.order.id, line_item_id: line_item.id, name: line_item.order.name, quantity: line_item.quantity) if (line_item.quantity.to_i > 0)

                  InventoryHistory.create(product_variant_id: item.product_variant_id, user_id: current_user.id, container_id: @container.id, event: "Container Arrived(#{line_item.order.name})", adjustment: 0, quantity:  ProductVariant.find_by(id: item.product_variant_id).inventory_quantity.to_i) if item.product_variant_id.present? && ProductVariant.find_by(id: item.product_variant_id).inventory_histories.present?
                  @order = item.line_item.order
                  Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
                  @order.update(staging_date: Date.today) if @order.order_status == "Staging"
                end
              end
              if item.line_item.present? && item.line_item.order.status == 'in_progress'
                item.line_item.order.shipping_details.each do |detail|
                  if detail.status == 'not_ready' && detail.line_items.length > 0 && detail.line_items.all? {|item| item.status == 'ready'}
                    detail.update(status: :staging)
                  end
                end
              end
            end
            if item.line_item.present?
              @order = item.line_item.order
              Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
            end
            if item.product_variant_id.present?
              @variant = ProductVariant.find_by(id: item.product_variant_id)
              Magento::UpdateOrder.new(@variant.store).update_quantity(@variant)
              Magento::UpdateOrder.new(@variant.store).update_arriving_case_1_3(@variant)
            end
          end
          ContainerPosting.create(container_id: @container.id, store: current_store)
        end
        redirect_to request.referrer
      end
      # Magento::UpdateOrder.new(current_store).update_container(@container)
    else
      render "dashboard/unauthorized"
    end
  end

  def pdf
    @container = Container.find_by(id: params[:container_id])
  end

  def show
    @order = Order.find_by(name: params[:name])
    @line_item = LineItem.find(params[:line_item_id])
    @purchase_item = PurchaseItem.find(params[:purchase_item_id])
  end

  def split_item
    ::Audited.store[:current_user] = current_user
    if params[:purchase_item1].present? && params[:purchase_item].present?
      @purchase_item1 = PurchaseItem.find_by(id: params[:purchase_item1].keys.first.to_i)
      if @purchase_item1.quantity == params[:purchase_item1].values[0].to_i + params[:purchase_item][0].to_i
        @purchase_item1.update(quantity: params[:purchase_item1].values[0].to_i)
        @purchase_item = @purchase_item1.purchase.purchase_items.build
        @purchase_item.product_variant_id = @purchase_item1.product_variant_id
        @purchase_item.product_id = @purchase_item1.product_id
        @purchase_item.purchase_type = @purchase_item1.purchase_type
        @purchase_item.status = @purchase_item1.status
        @purchase_item.quantity = params[:purchase_item][0].to_i
        @purchase_item.save
        LineItem.where(id: params[:line_item_ids]).update_all(purchase_item_id: @purchase_item.id)
      end
      redirect_to new_admin_container_path
    else
      @purchase_item1 = PurchaseItem.find_by(id: params[:purchase_item_id])
      @purchase = Purchase.find_by(id: @purchase_item1.purchase_id)
      @purchase_item = @purchase.purchase_items.build
      @purchase_item.product_variant_id = @purchase_item1.product_variant_id
      @purchase_item.product_id = @purchase_item1.product_id
      @purchase_item.purchase_type = @purchase_item1.purchase_type
    end
  end

  def mearge_item
    ::Audited.store[:current_user] = current_user
    if (params[:purchase_item_ids].present?)
      if (params[:purchase_item_ids].length > 1)
        @purchase_item = PurchaseItem.find_by(id: params[:purchase_item_ids].first.to_i)
        params[:purchase_item_ids].drop(1).each do |id|
          @purchase_item1 = PurchaseItem.find_by(id: id)
          LineItem.where(purchase_item_id: @purchase_item1.id).update_all(purchase_item_id: @purchase_item.id)
          @qty = (PurchaseItem.find_by(id: params[:purchase_item_ids].first.to_i).quantity.to_i + @purchase_item1.quantity)
          @purchase_item = PurchaseItem.find_by(id: params[:purchase_item_ids].first.to_i).update(quantity: @qty)
          PurchaseItem.find_by(id: id).audits.destroy_all
          PurchaseItem.find_by(id: id).destroy
          Audit.where(auditable_type: "PurchaseItem", auditable_id: id).destroy_all
        end
        redirect_to new_admin_container_path
      else
        redirect_to new_admin_container_path
      end
    else
      @purchase_items = PurchaseItem.where(product_variant_id: PurchaseItem.find(params[:purchase_item_id]).product_variant_id, status: :container_ready)
    end
  end

  def assign_order
    @container = Container.find(params[:container_id])
    @purchase_item = PurchaseItem.find(params[:purchase_item_id])
  end

  def add_item
    @container = Container.find(params[:container_id])
    @container.container_purchases.build
    @purchase_items = PurchaseItem.eager_load(:purchase).joins(:purchase).where(status: :container_ready, purchases: { store: current_store })
  end
  # def reassign_variant
  #   @product = Product.find(params[:product_id]) if params[:product_id].present?
  #   @product_variant = ProductVariant.find(params[:product_variant_id]) if params[:product_variant_id].present?

  #   @line_item = LineItem.create
  # end

  private

  def find_container
    @container = Container.find(params[:id])
  end

  def container_params
    params.require(:container).permit(:ocean_carrier_id, :warehouse_id, :supplier_id, :container_number, :shipping_date, :port_eta, :arriving_to_dc, :status, :store, :ocean_carrier, :carrier_serial_number, :received_date, container_purchases_attributes: [:container_id, :purchase_item_id, :id], container_costs_attributes: [:id, :container_id, :name, :amount], container_charges_attributes: [:id, :container_id, :charge, :quote, :invoice_number, :invoice_amount, :tax_amount, :invoice_difference, :posted, files: []])
  end
end
