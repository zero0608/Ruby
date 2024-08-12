class AddFinanceContainerFieldsToContainer < ActiveRecord::Migration[6.1]
  def change
    add_reference :containers, :container_posting, foreign_key: true
    add_reference :containers, :container_record, foreign_key: true
  end
end
