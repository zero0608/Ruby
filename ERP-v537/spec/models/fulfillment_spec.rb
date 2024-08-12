require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Fulfillment association' do
   it 'belongs_to order' do
      assc = described_class.reflect_on_association(:order)
      expect(assc.macro).to eq :belongs_to
   end 	
  end
end
