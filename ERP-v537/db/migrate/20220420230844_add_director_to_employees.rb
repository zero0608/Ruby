class AddDirectorToEmployees < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :is_director, :boolean, default: "false"
  end
end