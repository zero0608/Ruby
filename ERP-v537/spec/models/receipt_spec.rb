require 'rails_helper'

RSpec.describe Receipt, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Receipt association' do
   it 'belongs_to order_transaction' do
    assc = described_class.reflect_on_association(:order_transaction)
    expect(assc.macro).to eq :belongs_to
   end
  end  

end
