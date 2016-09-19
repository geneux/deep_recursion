require 'rails_helper'

describe Question do
  it { is_expected.to have_many(:answers).dependent(:destroy) }

  it { is_expected.to validate_presence_of :topic }
  it { is_expected.to validate_presence_of :body }

  it { is_expected.to validate_length_of(:topic).is_at_least(10) }
  it { is_expected.to validate_length_of(:topic).is_at_most(200) }
  it { is_expected.to validate_length_of(:body).is_at_least(20) }
  it { is_expected.to validate_length_of(:body).is_at_most(50_000) }

  it { is_expected.to have_db_index :user_id }

  it_behaves_like :user_related
  it_behaves_like :attachable

  it_behaves_like :rateable do
    let (:rateable) { create(:question, user: user) }
  end
end
