require 'rails_helper'

RSpec.describe AnswerPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:any_answer) { create(:answer) }
  let(:users_answer) { create(:answer, user: user) }

  permissions :show? do
    it('allow guest') { is_expected.to permit(nil, any_answer) }
  end

  permissions :show?, :create?, :rate? do
    it('allow user') { is_expected.to permit(user, any_answer) }
  end

  permissions :show?, :create?, :update?, :destroy?, :rate? do
    it('allow admin') { is_expected.to permit(create(:user, admin: true), any_answer) }
  end

  permissions :create?, :update?, :destroy?, :rate?, :star? do
    it('deny guest') { is_expected.not_to permit(nil, any_answer) }
  end

  permissions :update?, :destroy? do
    it('allow author') { is_expected.to permit(user, users_answer) }
  end

  permissions :update?, :destroy?, :star? do
    it('deny user') { is_expected.not_to permit(user, any_answer) }
  end

  permissions :rate?, :star? do
    it('deny author') { is_expected.not_to permit(user, users_answer) }
  end

  permissions :star? do
    it('allow Question\'s author') do
      is_expected.to permit(user, create(:answer, question: create(:question, user: user)))
    end
  end
end
