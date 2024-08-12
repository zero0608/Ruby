class AddCubicMetersToCartonDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :carton_details, :cubic_meter, :float
  end
end
