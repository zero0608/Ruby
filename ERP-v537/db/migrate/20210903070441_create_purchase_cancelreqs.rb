class CreatePurchaseCancelreqs < ActiveRecord::Migration[6.1]
  def change
    create_table :purchase_cancelreqs do |t|
      t.references :purchase, null: false, foreign_key: true
      t.references :purchase_item, null: false, foreign_key: true
      t.integer :cancel_quantity

      t.timestamps
    end
  end
end
