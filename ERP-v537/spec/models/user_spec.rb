require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'User association' do
    it 'belongs_to user_group' do
	    assc = described_class.reflect_on_association(:user_group)
	    expect(assc.macro).to eq :belongs_to
	  end
	  it 'has_many issues' do
	    assc = described_class.reflect_on_association(:issues)
	    expect(assc.macro).to eq :has_many
	  end

  end
end
