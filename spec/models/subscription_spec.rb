require 'rails_helper'

describe Subscription do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :question }

  it { is_expected.to validate_presence_of :user_id }
  it { is_expected.to validate_presence_of :question_id }

  it do
    subject.user = build(:user)
    subject.question = build(:question)
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:question_id)
  end
end
