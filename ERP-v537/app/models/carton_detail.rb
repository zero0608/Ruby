# frozen_string_literal: true

class CartonDetail < ApplicationRecord
  belongs_to :product, optional: true

  has_many :cartons, dependent: :destroy
 
  audited associated_with: :product
 
  after_save do
    if length.present?
      self.update_columns(cubic_meter: add_cubic_meter, length: length)
    end
  end

  def convert_to_meter(data)
    data/39.37
  end

  def add_cubic_meter
    cubic_data = convert_to_meter(length.to_i) * convert_to_meter(width.to_i) * convert_to_meter(height.to_i)
    cubic_data
  end
end
