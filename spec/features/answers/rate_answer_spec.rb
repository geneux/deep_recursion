require 'features_helper'

feature 'Rate the Answer', %q(
  To select the best Answer
  As a User
  I want to rate other Users' Answers and revoke my ratings
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: other_user) }

  describe 'Authenticated User' do
    before do
      sign_in user
      visit question_path(question)
    end

    scenario 'can see Answer Rating' do
      within "#answer-#{answer.id}" do
        expect(page).to have_content 'Rating: '
      end
    end

    scenario 'can rate other User\'s Answer' do
      within "#answer-#{answer.id}" do
        expect(page).to have_link 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'can increment rate', :js do
      within "#answer-#{answer.id}" do
        click_on 'GLYPH:plus-sign'
      end

      within "#rating-#{answer.id}" do
        expect(page).to have_content '1'
      end
    end

    scenario 'can decrement rate', :js do
      within "#answer-#{answer.id}" do
        click_on 'GLYPH:minus-sign'
      end

      within "#rating-#{answer.id}" do
        expect(page).to have_content '-1'
      end
    end

    scenario 'cannot see links to rate other User\'s Answer second time', :js do
      within "#answer-#{answer.id}" do
        click_on 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'cannot see links to rate own Answer' do
      alt_answer = create(:answer, question: question, user: user)
      visit question_path(question)

      within "#answer-#{alt_answer.id}" do
        expect(page).to_not have_link 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'can revoke own rating and rate other Answer', :js do
      alt_answer = create(:answer, question: question)
      visit question_path(question)

      within "#answer-#{answer.id}" do
        click_on 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:remove-circle'

        click_on 'GLYPH:remove-circle'
      end

      within "#answer-#{alt_answer.id}" do
        expect(page).to have_link 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:minus-sign'
      end
    end
  end

  scenario 'Unauthenticated user cannot see links to rate the Answer' do
    visit question_path(question)

    within '#answers' do
      expect(page).to have_content 'Rating: '
      expect(page).to_not have_link 'GLYPH:plus-sign'
      expect(page).to_not have_link 'GLYPH:minus-sign'
    end
  end
end
