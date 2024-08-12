class AddBillingMethodToCarrier < ActiveRecord::Migration[6.1]
  def change
    add_column :carriers, :billing_method, :string
  end
end
