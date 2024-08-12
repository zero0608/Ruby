class WhiteGloveAddress < ApplicationRecord
  belongs_to :white_glove_directory, optional: true
  has_many :shipping_details, dependent: :nullify
  has_many :returns, dependent: :nullify
end