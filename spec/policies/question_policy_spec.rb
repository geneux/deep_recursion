require 'rails_helper'

describe QuestionPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:any_question) { create(:question) }
  let(:users_question) { create(:question, user: user) }

  permissions :show? do
    it('allow guest') { is_expected.to permit(nil, any_question) }
  end

  permissions :show?, :create?, :rate?, :subscribe? do
    it('allow user') { is_expected.to permit(user, any_question) }
  end

  permissions :show?, :create?, :update?, :destroy?, :rate?, :subscribe? do
    it('allow admin') { is_expected.to permit(create(:user, admin: true), any_question) }
  end

  permissions :create?, :update?, :destroy?, :rate?, :subscribe? do
    it('deny guest') { is_expected.not_to permit(nil, any_question) }
  end

  permissions :update?, :destroy? do
    it('allow author') { is_expected.to permit(user, users_question) }
    it('deny user') { is_expected.not_to permit(user, any_question) }
  end

  permissions :rate? do
    it('deny author') { is_expected.not_to permit(user, users_question) }
  end
end
