class Admin::ReturnLineItemsController < ApplicationController
  def update
    @return_line_item = ReturnLineItem.find(params[:id])
    @return_line_item.update(return_line_item_params)

    if @return_line_item.status == "return_to_stock"
      unless @return_line_item.new_packaging
        quantity = @return_line_item.line_item&.variant&.inventory_quantity.to_i
        @return_line_item.line_item&.variant&.update(old_inventory_quantity: quantity, inventory_quantity: quantity + @return_line_item.quantity)
        InventoryHistory.create(product_variant_id: @return_line_item.line_item&.variant&.id, user_id: current_user.id, event: "Return received (#{@return_line_item.return.name})", adjustment: @return_line_item.quantity.to_i, quantity: @return_line_item.line_item&.variant&.inventory_quantity.to_i)
      end

    elsif @return_line_item.status == "overstock"
      products = ReturnProduct.eager_load(:line_item).where(line_items: { variant_id: @return_line_item.line_item.variant_id })
      if products.present?
        products.first.update(quantity: products.first.quantity + @return_line_item.quantity)
      else
        ReturnProduct.create(order_id: @return_line_item.return.order.id, issue_id: @return_line_item.return.issue.id, line_item_id: @return_line_item.line_item.id, status: :pending, quantity: @return_line_item.quantity)
      end

    elsif @return_line_item.status == "marketplace"
      products = MarketProduct.eager_load(:line_item).where(line_items: { variant_id: @return_line_item.line_item.variant_id })
      if products.present?
        products.first.update(quantity: products.first.quantity + @return_line_item.quantity)
      else
        MarketProduct.create(order_id: @return_line_item.return.order.id, issue_id: @return_line_item.return.issue.id, line_item_id: @return_line_item.line_item.id, status: :pending, quantity: @return_line_item.quantity, quote_amount: @return_line_item.market_value)
      end
    end

    if @return_line_item.return.return_line_items.all? { |li| li.status != "pending" }
      @return_line_item.return.update(status: :complete)
    end

    redirect_to edit_admin_return_path(@return_line_item.return_id)
  end
  
  private

  def return_line_item_params
    params.require(:return_line_item).permit(:id, :status, :market_value, :package_condition, :product_condition, :new_packaging, :notes)
  end
end