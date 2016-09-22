require 'features_helper'

feature 'Authenticated User can (un)subscribe to any Question', %q(
  To be able to be notified about new Answers
  As an authenticated User
  I want to subscribe and unsubscribe to any Question
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated User' do
    before { sign_in user }

    context 'as not a Question author' do
      context 'if not subscribed' do
        include_examples :can_subscribe_unsubscribe, true
      end

      context 'if subscribed' do
        before { create(:subscription, user: user, question: question) }
        include_examples :can_subscribe_unsubscribe, false
      end
    end

    context 'as a Question author' do
      given!(:question) { create(:question, user: user) }
      include_examples :can_subscribe_unsubscribe, false
    end
  end

  describe 'Unauthenticated User' do
    before { visit question_path(question) }

    scenario 'cannot subscribe' do
      expect(page).not_to have_button 'Subscribe'
    end

    scenario 'cannot unsubscribe' do
      expect(page).not_to have_button 'Unsubscribe'
    end
  end
end
