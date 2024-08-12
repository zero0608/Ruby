class CreateContainerCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :container_charges do |t|
      t.references :container, null: false, foreign_key: true
      t.string :carrier_type
      t.string :charge
      t.float :quote
      t.float :invoice_amount
      t.float :invoice_difference
      t.float :tax_amount
      t.boolean :posted

      t.timestamps
    end
  end
end
