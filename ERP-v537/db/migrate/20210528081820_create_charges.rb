class CreateCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :charges do |t|
      t.references :receipt, null: false, foreign_key: true
      t.string :object
      t.string :amount
      t.string :application_fee
      t.string :balance_transaction
      t.string :captured
      t.string :currency
      t.string :failure_code
      t.string :failure_message
      t.json :fraud_details
      t.string :livemode
      t.string :paid
      t.string :payment_intent
      t.string :payment_method
      t.string :refunded
      t.string :source
      t.string :status
      t.json :mit_params

      t.timestamps
    end
  end
end
