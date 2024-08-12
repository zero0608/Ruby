class Admin::WarehouseTransferOrdersController < ApplicationController
  require 'arrays'
  def index
    @transfer_orders = WarehouseTransferOrder.all
  end

  def new
    @warehouse = Warehouse.where(store: current_store).find_by_name(params[:warehouse_name])
    @transfer_order = WarehouseTransferOrder.new(from_warehouse_id: @warehouse.id, from_store: @warehouse.store)
    @warehouse_transfer_items = @transfer_order.warehouse_transfer_items
    # @warehouse_variants = @warehouse.warehouse_variants
  end

  def create
    @warehouse = Warehouse.where(store: current_store).find(params[:warehouse_id]) if params[:warehouse_id].present?
    if params[:transfer].present?
      params[:transfer][:war_var_ids].each do |id|
        quantity = params[:transfer][:quantity].values_at(id)[0][0].to_i
        @war_var = WarehouseVariant.find(id)
        @transfer_order.warehouse_transfer_items.build(product_variant_id: @war_var.product_variant_id, warehouse_variant_id: @war_var.id, quantity: quantity, store: @war_var.product_variant.store)
      end
      redirect_to new_admin_warehouse_transfer_order_path(warehouse_name: @warehouse.name)
    else
      @transfer_order =  WarehouseTransferOrder.new(warehouse_transfer_orders_params)
      @transfer_order.save
      @transfer_order.update(from_store: @transfer_order.from_warehouse.store, to_store: @transfer_order.to_warehouse.store)
      $array_for_warehouse_items.each do |item|
        item_attributes = {
          product_variant_id: item.product_variant_id,
          warehouse_variant_id: item.warehouse_variant_id,
          quantity: item.quantity,
          store: item.store
        }
        if item.product_variant.inventory_quantity.to_i > item.quantity.to_i
          @transfer_item = @transfer_order.warehouse_transfer_items.build(item_attributes)
          @transfer_item.save
          if @transfer_order.from_store == @transfer_order.to_store
            @transfer_item.warehouse_variant.update(warehouse_quantity: (@transfer_item.warehouse_variant.warehouse_quantity.to_i - @transfer_item.quantity.to_i))
          else
            @transfer_item.warehouse_variant.update(warehouse_quantity: (@transfer_item.warehouse_variant.warehouse_quantity.to_i - @transfer_item.quantity.to_i))
            @transfer_item.product_variant.update(inventory_quantity: (@transfer_item.product_variant.inventory_quantity.to_i - @transfer_item.quantity.to_i))
          end
        end
        $array_for_warehouse_items.delete(item)
      end
    end
    redirect_to admin_warehouse_transfer_orders_path
  end

  def shipped_transfer
    transfer_order = WarehouseTransferOrder.find(params[:transfer_order_id])
    from_warehouse = transfer_order.from_warehouse
    to_warehouse = transfer_order.to_warehouse
    if transfer_order.from_store == transfer_order.to_store
      transfer_order.warehouse_transfer_items.each do |item|
        to_warehouse_variant = WarehouseVariant.find_by(warehouse_id: to_warehouse.id, product_variant_id: item.product_variant_id)
        from_warehouse_variant = WarehouseVariant.find_by(warehouse_id: from_warehouse.id, product_variant_id: item.product_variant_id)
        if to_warehouse_variant.present?
          to_warehouse_variant.update(warehouse_quantity: (to_warehouse_variant.warehouse_quantity.to_i + item.quantity.to_i))
        else
          WarehouseVariant.create(warehouse_id: to_warehouse.id, product_variant_id: item.product_variant_id, warehouse_quantity: item.quantity.to_i)
          # item.product_variant.update(inventory_quantity: (item.product_variant.inventory_quantity.to_i - item.quantity.to_i))
        end
        # from_warehouse_variant.update(warehouse_quantity: (from_warehouse_variant.warehouse_quantity.to_i - item.quantity.to_i))
        InventoryHistory.create(product_variant_id: to_warehouse_variant.product_variant.id, user_id: current_user.id, event: "Warehouse transfer done of quantity #{item.quantity} from #{from_warehouse.name} of #{transfer_order.from_store} to #{to_warehouse.name} of #{transfer_order.to_store} ", adjustment: 0, quantity: 0)
      end
    else
      transfer_order.warehouse_transfer_items.each do |item|
        from_warehouse_variant = WarehouseVariant.find_by(warehouse_id: from_warehouse.id, product_variant_id: item.product_variant_id)
        from_variant = from_warehouse_variant.product_variant
        to_variant = ProductVariant.find_by(store: transfer_order.to_store, sku: from_variant.sku)
        if to_variant.present?
          to_warehouse_variant = WarehouseVariant.find_by(warehouse_id: to_warehouse.id, product_variant_id: to_variant.id)
          if to_warehouse_variant.present?
            to_warehouse_variant.update(warehouse_quantity: (to_warehouse_variant.warehouse_quantity.to_i + item.quantity.to_i))
          else
            WarehouseVariant.create(warehouse_id: to_warehouse.id, product_variant_id: item.product_variant_id, warehouse_quantity: item.quantity.to_i, store: to_warehouse.store)
            # item.product_variant.update(inventory_quantity: (item.product_variant.inventory_quantity.to_i - item.quantity.to_i))
          end
          to_variant.update(inventory_quantity: (to_variant.inventory_quantity.to_i + item.quantity.to_i))
          # from_warehouse_variant.update(warehouse_quantity: (from_warehouse_variant.warehouse_quantity.to_i - item.quantity.to_i))
          # from_warehouse_variant.product_variant.update(inventory_quantity: (from_warehouse_variant.product_variant.inventory_quantity.to_i - item.quantity.to_i))
          InventoryHistory.create(product_variant_id: to_variant.id, user_id: current_user.id, event: "Warehouse transfer from #{from_warehouse.name} of #{transfer_order.from_store} to #{to_warehouse.name} of #{transfer_order.to_store} ", adjustment: item.quantity, quantity: (to_variant.inventory_quantity.to_i))
        end
      end
    end
    transfer_order.update(status: :shipped)
    redirect_to admin_warehouse_transfer_orders_path
  end

  def edit
  end

  def update
  end

  def show
    @transfer_order = WarehouseTransferOrder.find(params[:id])
  end

  def add_product
    @warehouse = Warehouse.where(store: current_store).find(params[:warehouse_id])
    @transfer_order = WarehouseTransferOrder.new
  end

  def clear_array
    $array_for_warehouse_items = []
    redirect_to admin_warehouse_transfer_orders_path
  end

  private

  def warehouse_transfer_orders_params
    params.require(:warehouse_transfer_order).permit(:from_warehouse_id, :to_warehouse_id, :name, :status, :etc_date, :customer_name, :from_store, :to_store, :to_warehouse, :form_warehouse)
  end
end
