# frozen_string_literal: true

class BillingAddress < ApplicationRecord
  belongs_to :order

  def complete_address
    address1.to_s.tr('["]', '') + ", " + city.to_s + ", " + address2.to_s + " " + country.to_s + " " + zip.to_s
  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      email
    end
  end
end
