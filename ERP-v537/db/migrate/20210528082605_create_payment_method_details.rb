class CreatePaymentMethodDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_method_details do |t|
      t.references :charge, null: false, foreign_key: true
      t.json :card
      t.string :type


      t.timestamps
    end
  end
end
