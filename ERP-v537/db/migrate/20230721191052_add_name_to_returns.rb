class AddNameToReturns < ActiveRecord::Migration[6.1]
  def change
    add_column :returns, :name, :string
  end
end
