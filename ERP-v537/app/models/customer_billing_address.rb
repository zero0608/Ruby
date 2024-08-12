class CustomerBillingAddress < ApplicationRecord
  belongs_to :customer

  def complete_address
    address.to_s + ", " + city.to_s + ", " + state.to_s + " " + full_country + " " + zip.to_s
  end

  def full_country
    if country == "us"
      country&.upcase.to_s
    else
      country&.titleize.to_s
    end
  end

  def full_name
    if first_name.present? && last_name.present?
      first_name + " " + last_name
    elsif first_name.present?
      first_name
    end
  end
end