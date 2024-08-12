# frozen_string_literal: true

class WarehouseTransferOrderReflex < ApplicationReflex
  require 'arrays'

  def search_variant
    @que = element[:value].strip
    @warehouse = Warehouse.find(element.dataset[:warehouse_id])
    @warehouse_variants = @warehouse.warehouse_variants.eager_load(:product_variant).includes(:product_variant).where("(product_variants.title ILIKE ? OR product_variants.sku ILIKE ?)", "%#{@que}%", "%#{@que}%") if @que.present?
    assigns = {
      warehouse: @warehouse,
      query: @que,
      warehouse_variants: @warehouse_variants
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#warehouse-variant-search-edit-results", html: render(partial: "search_variant", assigns: assigns))
      .push_state()
      .broadcast
  end

  def submit
    @warehouse = Warehouse.find(element.dataset[:warehouse_id])
    @transfer_order = WarehouseTransferOrder.new(from_warehouse_id: @warehouse.id, from_store: @warehouse.store)
    if params[:transfer].present?
      params[:transfer][:war_var_ids].each do |id|
        unless $array_for_warehouse_items.pluck(:warehouse_variant_id).include? id.to_i
          quantity = params[:transfer][:quantity].values_at(id)[0][0].to_i
          @war_var = WarehouseVariant.find(id)
          @item = @transfer_order.warehouse_transfer_items.build(product_variant_id: @war_var.product_variant_id, warehouse_variant_id: @war_var.id, quantity: quantity, store: @war_var.product_variant.store)
          $array_for_warehouse_items << @item
        end
      end
    end
    assigns = {
      warehouse: @warehouse,
      query: @que,
      warehouse_transfer_items: @transfer_order.warehouse_transfer_items
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#warehouse-item-results", html: render(partial: "result_items", assigns: assigns))
      .push_state()
      .broadcast
  end
end