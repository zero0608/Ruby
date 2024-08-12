class AddReplacementTypeToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :replacement_type, :integer
  end
end
