class CarrierReflex < ApplicationReflex
  def add_contact
    Carrier.find_by(id: element.dataset[:id]).carrier_contacts.create()
  end

  def delete_contact
    CarrierContact.find_by(id: element.dataset[:id]).destroy
  end
end