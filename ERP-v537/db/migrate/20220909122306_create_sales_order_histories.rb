class CreateSalesOrderHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :sales_order_histories do |t|
      t.references :deal, null: true, foreign_key: true
      t.references :sales_contact, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.string :note

      t.timestamps
    end
  end
end
