class CreateRefundItems < ActiveRecord::Migration[6.1]
  def change
    remove_column :issues, :assign_product, :json
    remove_column :issues, :manufacturing_category, :integer
    remove_column :issues, :shipping_category, :integer
    add_column :issues, :full_refund, :boolean, default: "false"
    add_column :issues, :discount_amount, :float
    add_column :issues, :warranty_amount, :float
    add_column :issues, :gorgias_ticket, :string
    add_column :issues, :claim_type, :integer
    add_column :expenses, :claims_expense, :boolean, default: "false"

    create_table :claims_refund_items do |t|
      t.integer :quantity
      
      t.references :issue, null: true, foreign_key: true
      t.references :line_item, null: true, foreign_key: true

      t.timestamps
    end

    create_table :repair_services do |t|
      t.string :repair_type
      t.float :amount
      t.references :issue, foreign_key: true
      t.timestamps
    end
  end
end
