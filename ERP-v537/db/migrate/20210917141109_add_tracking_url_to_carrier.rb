class AddTrackingUrlToCarrier < ActiveRecord::Migration[6.1]
  def change
    add_column :carriers, :tracking_url, :string
  end
end
