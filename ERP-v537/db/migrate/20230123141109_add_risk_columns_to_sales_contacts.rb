class AddRiskColumnsToSalesContacts < ActiveRecord::Migration[6.1]
  def change
    add_reference :sales_contacts, :risk_indicator, foreign_key: true, null: true
    add_column :sales_contacts, :risk_reason, :string
  end
end
