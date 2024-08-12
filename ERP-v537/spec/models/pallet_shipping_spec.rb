require 'rails_helper'

RSpec.describe PalletShipping, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'PalletShipping association' do
   it 'belongs_to order' do
      assc = described_class.reflect_on_association(:order)
      expect(assc.macro).to eq :belongs_to
   end
   it 'belongs_to pallet' do
      assc = described_class.reflect_on_association(:pallet)
      expect(assc.macro).to eq :belongs_to
   end
   it 'belongs_to shipping_detail' do
      assc = described_class.reflect_on_association(:shipping_detail)
      expect(assc.macro).to eq :belongs_to
   end
 end
end
