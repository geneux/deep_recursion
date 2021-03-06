require 'features_helper'

feature 'User can delete own answer', %q(
  To delete unneeded answer which I made
  As an authenticated user
  I want to delete an answer
) do
  given(:user) { create(:user) }
  given(:question_user) { create(:user) }
  given(:question) { create(:question, user: question_user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  describe 'Authenticated User' do
    before do
      sign_in user
      visit question_path(question)
    end

    scenario 'can delete own answer', :js do
      within "#answer-#{answer.id}" do
        click_on 'Delete'
      end

      expect(page).not_to have_content answer.body
      expect(has_no_css?("#answer-#{answer.id}")).to be true
      expect(current_path).to eq question_path(question)
    end

    scenario 'can\'t see a button to delete other user\'s answer' do
      answer = create(:answer, question: question, user: create(:user))
      answer.reload

      expect(page).not_to have_link "#delete-answer-#{answer.id}"
    end
  end


  scenario 'Unauthenticated user don\'t see delete answer button' do
    visit question_path(question)

    expect(page).not_to have_link "#delete-answer-#{answer.id}"
  end
end
