class AddCarrierToIssue < ActiveRecord::Migration[6.1]
  def change
    add_reference :issues, :carrier, foreign_key: true
  end
end
