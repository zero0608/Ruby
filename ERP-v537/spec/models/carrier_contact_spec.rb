require 'rails_helper'

RSpec.describe CarrierContact, type: :model do

  describe 'CarrierContact association' do
    it "belongs_to carrier" do
      assc = described_class.reflect_on_association(:carrier)
      expect(assc.macro).to eq :belongs_to
    end
  end

end
