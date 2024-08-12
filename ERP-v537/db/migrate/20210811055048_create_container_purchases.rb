class CreateContainerPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :container_purchases do |t|
      t.references :container, null: false, foreign_key: true
      t.references :purchase_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
