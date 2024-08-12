class AddContainerIdToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :line_items, :container, foreign_key: true, null: true
  end
end
