require 'features_helper'

feature 'Rate the Question', %q(
  To select the best Question
  As a User
  I want to rate other Users' Questions and revoke my rating
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given!(:question) { create(:question, user: other_user) }

  describe 'Authenticated User' do
    before do
      sign_in user
      visit questions_path
    end

    scenario 'can see Question Rating' do
      within "#question-#{question.id}" do
        expect(page).to have_content 'Rating: '
      end
    end

    scenario 'can rate other User\'s Question' do
      within "#question-#{question.id}" do
        expect(page).to have_link 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'can increment rate', :js do
      within "#question-#{question.id}" do
        click_on 'GLYPH:plus-sign'
      end

      within "#rating-#{question.id}" do
        expect(page).to have_content '1'
      end
    end

    scenario 'can decrement rate', :js do
      within "#question-#{question.id}" do
        click_on 'GLYPH:minus-sign'
      end

      within "#rating-#{question.id}" do
        expect(page).to have_content '-1'
      end
    end

    scenario 'cannot see links to rate other User\'s Question second time', :js do
      within "#question-#{question.id}" do
        click_on 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'cannot see links to rate own Question' do
      alt_question = create(:question, user: user)
      visit questions_path

      within "#question-#{alt_question.id}" do
        expect(page).to_not have_link 'GLYPH:plus-sign'
        expect(page).to_not have_link 'GLYPH:minus-sign'
      end
    end

    scenario 'can revoke own rating and rate other Question', :js do
      alt_question = create(:question)
      visit questions_path

      within "#question-#{question.id}" do
        click_on 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:remove-circle'

        click_on 'GLYPH:remove-circle'
      end

      within "#question-#{alt_question.id}" do
        expect(page).to have_link 'GLYPH:plus-sign'
        expect(page).to have_link 'GLYPH:minus-sign'
      end
    end
  end

  scenario 'Unauthenticated user cannot see links to rate the Question' do
    visit questions_path

    within '#questions' do
      expect(page).to have_content 'Rating: '
      expect(page).to_not have_link 'GLYPH:plus-sign'
      expect(page).to_not have_link 'GLYPH:minus-sign'
    end
  end
end
