require 'rails_helper'

RSpec.describe Supplier, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Supplier association' do
   it 'has_many products' do
    assc = described_class.reflect_on_association(:products)
    expect(assc.macro).to eq :has_many
   end   
  end
end
