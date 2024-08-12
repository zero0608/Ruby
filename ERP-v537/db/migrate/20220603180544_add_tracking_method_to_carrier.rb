class AddTrackingMethodToCarrier < ActiveRecord::Migration[6.1]
  def change
    add_column :carriers, :tracking_method, :string
  end
end
