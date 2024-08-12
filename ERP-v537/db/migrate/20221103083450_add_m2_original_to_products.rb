class AddM2OriginalToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :m2_original, :string
  end
end
