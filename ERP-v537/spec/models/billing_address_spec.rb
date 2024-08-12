require 'rails_helper'

RSpec.describe BillingAddress, type: :model do

  describe 'BillingAddress association' do
	  it "belongs_to order" do
	    assc = described_class.reflect_on_association(:order)
	    expect(assc.macro).to eq :belongs_to
	  end
	end
end
