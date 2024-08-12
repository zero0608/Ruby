class AddListGroupIdToChecklists < ActiveRecord::Migration[6.1]
  def change
    add_reference :checklists, :list_group, foreign_key: { to_table: :checklists }
  end
end
