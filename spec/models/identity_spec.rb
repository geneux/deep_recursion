require 'rails_helper'

describe Identity do
  it { is_expected.to validate_presence_of :uid }
  it { is_expected.to validate_presence_of :provider }

  it_behaves_like :user_related

  describe 'validates uniqueness of uid in context of the provider' do
    subject { create(:identity) }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
  end
end
