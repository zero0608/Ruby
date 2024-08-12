class CreateReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :receipts do |t|
      t.references :transactions, null: false, foreign_key: true
      t.string :amount
      t.json :balance_transaction
      t.string :object
      t.string :reason
      t.string :status
      t.string :created
      t.string :currency
      t.json :payment_method_details
      t.json :mit_params


      t.timestamps
    end
  end
end
