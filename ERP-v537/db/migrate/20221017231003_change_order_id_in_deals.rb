class ChangeOrderIdInDeals < ActiveRecord::Migration[6.1]
  def change
    remove_column :deals, :order_id, :bigint
    add_column :deals, :tag_order_id, :string
  end
end
