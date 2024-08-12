class AddStoreToContainarFinance < ActiveRecord::Migration[6.1]
  def change
    add_column :container_postings, :store, :string
    add_column :container_records, :store, :string
  end
end
