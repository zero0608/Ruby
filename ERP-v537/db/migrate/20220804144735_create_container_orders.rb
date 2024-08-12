class CreateContainerOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :container_orders do |t|
      t.references :product_variant, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.references :line_item, null: true, foreign_key: true

      t.string :name
      t.integer :quantity

      t.timestamps
    end
  end
end
