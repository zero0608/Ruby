class AddStoreCreditToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :store_credit, :float
  end
end
