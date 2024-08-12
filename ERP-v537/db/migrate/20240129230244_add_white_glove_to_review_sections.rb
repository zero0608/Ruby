class AddWhiteGloveToReviewSections < ActiveRecord::Migration[6.1]
  def change
    add_column :review_sections, :white_glove, :boolean
    add_column :posting_sections, :white_glove, :boolean
    add_column :record_sections, :White_glove, :boolean
    add_reference :returns, :white_glove_directory, foreign_key: true
    add_reference :returns, :white_glove_address, foreign_key: true
  end
end
