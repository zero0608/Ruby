class ChangeOrdeIdInDeals2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :deals, :tag_order_id, :string
    add_reference :deals, :order, foreign_key: true, null: true
  end
end
