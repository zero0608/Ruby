# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :subcategories, dependent: :destroy

  accepts_nested_attributes_for :subcategories, allow_destroy: true, reject_if: :all_blank
end
