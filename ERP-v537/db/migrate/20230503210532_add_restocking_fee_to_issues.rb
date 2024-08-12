class AddRestockingFeeToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :restocking_fee, :float
    add_column :issues, :repacking_fee, :float
    add_column :return_products, :quantity, :integer

    create_table :market_products do |t|
      t.references :order, null: true, foreign_key: true
      t.references :issue, null: true, foreign_key: true
      t.references :line_item, null: true, foreign_key: true
      t.integer :status
      t.integer :quantity
      t.float :quote_amount
      
      t.timestamps
    end
    

    create_table :returns do |t|
      t.integer :status
      t.boolean :customer_return, default: false
      t.boolean :disposal, default: false
      t.string :return_reason
      t.date :return_date
      t.string :return_carrier
      t.string :return_number
      t.float :return_quote

      t.string :return_company
      t.string :return_contact
      t.string :return_address
      t.string :return_city
      t.string :return_state
      t.string :return_country
      t.string :return_zip_code
      
      t.references :order, null: true, foreign_key: true
      t.references :issue, null: true, foreign_key: true

      t.timestamps
    end

    create_table :return_line_items do |t|
      t.integer :status
      t.integer :quantity
      t.boolean :package_condition, default: false
      t.boolean :product_condition, default: false
      t.boolean :new_packaging, default: false
      t.float :market_value
      t.string :notes

      t.references :return, null: true, foreign_key: true
      t.references :line_item, null: true, foreign_key: true
      t.timestamps
    end
  end
end
