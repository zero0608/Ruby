class AddChargebackDateToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :chargeback_date, :date
    add_column :issues, :card_type, :integer
  end
end
