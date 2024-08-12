class Admin::LineItemsController < ApplicationController
  def update
    ::Audited.store[:current_user] = current_user
    @line_item = LineItem.find(params[:id])
    @line_item.update(line_item_params)
  end

  private

  def line_item_params
    params.require(:line_item).permit(:id, :reserve)
  end
end