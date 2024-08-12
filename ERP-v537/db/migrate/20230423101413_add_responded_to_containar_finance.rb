class AddRespondedToContainarFinance < ActiveRecord::Migration[6.1]
  def change
    add_column :container_postings, :responded, :integer
    add_column :container_records, :responded, :integer
  end
end
