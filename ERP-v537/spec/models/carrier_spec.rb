require 'rails_helper'

RSpec.describe Carrier, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Carrier association' do
   it 'has many carrier contacts' do
      assc = described_class.reflect_on_association(:carrier_contacts)
      expect(assc.macro).to eq :has_many
   end 	
  end 

end
