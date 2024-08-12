class Supplier < ApplicationRecord
  has_many :products
  has_many :users, dependent: :destroy
  has_many :product_variants
  has_many :issues
  accepts_nested_attributes_for :users, allow_destroy: true, reject_if: :all_blank

  extend FriendlyId
  friendly_id :name, :use => :slugged

  validates :name, uniqueness: { case_sensitive: false }
end
