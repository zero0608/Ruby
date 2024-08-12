class ChangeDeals < ActiveRecord::Migration[6.1]
  def change
    remove_column :deals, :name, :string
    remove_column :deals, :email, :string
    remove_column :deals, :phone, :string
    remove_column :deals, :sales_revenue, :string
    remove_column :deals, :street, :string
    remove_column :deals, :city, :string
    remove_column :deals, :state, :string
    remove_column :deals, :country, :string
    remove_column :deals, :zip_code, :string
    remove_column :deals, :trade, :string
    remove_column :deals, :designer, :boolean
    remove_column :deals, :secondary_phone, :string
    remove_column :deals, :trade_name, :string
    change_column :deals, :lead_value, "float USING CAST(lead_value AS float)"
    add_column :deals, :deal_owner, :integer
  end
end
