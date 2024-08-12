class AddPreorderToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :preorder_quantity, :integer
    create_table :reserve_items do |t|
      t.references :line_item, foreign_key: true
      t.references :carton, foreign_key: true
      t.integer :quantity
    end
  end
end