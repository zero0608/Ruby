class DropDeals < ActiveRecord::Migration[6.1]
  def change
    remove_reference :invoices, :deal, foreign_key: true
    add_reference :invoices, :customer, foreign_key: true
    
    drop_table :deals do |t|
      t.string :description
      t.integer :stage
      t.float :lead_value
      t.integer :source
      t.string :deal_name
      t.date :closing_date
      t.string :notes_title
      t.string :notes
      t.integer :sales_status
      t.references :order
      t.json :stage_date
      t.boolean :archived
      t.references :customer
      t.references :employee

      t.timestamps
    end

    add_column :invoices, :source, :integer
    add_column :invoices, :invoice_generated, :boolean
    add_column :invoices, :payment_method, :integer
    remove_column :invoices, :invoice_date, :date
  end
end