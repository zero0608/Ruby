class BoardSection < ApplicationRecord
  has_many :board_pages, dependent: :destroy
end