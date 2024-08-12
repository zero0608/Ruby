class ChangeDataTypeForDescription < ActiveRecord::Migration[6.1]
  def change
    change_column :issues, :description, :text
  end
end
