class AddEmployeeToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :employee, foreign_key: true
  end
end
