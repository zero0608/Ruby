class AddCommentDescriptionToPurchaseItem < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :comment_description, :text
  end
end
