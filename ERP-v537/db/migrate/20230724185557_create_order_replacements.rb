class CreateOrderReplacements < ActiveRecord::Migration[6.1]
  def change
    create_table :order_replacements do |t|
      t.references :order, foreign_key: true
      t.references :replacement_reference, foreign_key: true
      t.integer :quantity

      t.timestamps
    end

    add_column :replacements, :quantity, :integer
  end
end
