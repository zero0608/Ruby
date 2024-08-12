require 'rails_helper'

RSpec.describe PaymentMethodDetail, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'PaymentMethodDetail association' do
   it 'belongs_to charge' do
      assc = described_class.reflect_on_association(:charge)
      expect(assc.macro).to eq :belongs_to
   end
  end
end
