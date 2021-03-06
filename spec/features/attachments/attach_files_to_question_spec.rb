require 'features_helper'

feature 'Attach files to Question', %q(
  To provide extra data
  As a Question author
  I want to attach files to the Question
) do
  given(:user) { create(:user) }

  let(:ask_question) do
    click_on 'Ask Question'
    expect(page).to have_link @question_topic
    click_on @question_topic
  end

  background do
    DatabaseCleaner.clean
    sign_in user
    visit questions_path
    @question_topic = Faker::Lorem.sentence
    fill_in 'Question topic:', with: @question_topic
    fill_in 'Question:', with: Faker::Lorem.paragraph(4, true, 8)
  end

  scenario 'User attaches more than one file when creates a Question', :js do
    file_names = %w(README.md Gemfile .ruby-version)
    file_names.each_with_index do |file_name, cnt|
      within page.all('.nested-fields').last do
        attach_file 'File', "#{Rails.root}/#{file_name}"
      end
      click_on 'Add attachment'
    end

    ask_question

    file_names.each_with_index do |file_name, cnt|
      expect(page).to have_link file_name,
          href: "/uploads/attachment/file/#{cnt + 1}/#{file_name}"
    end
  end

  scenario 'User attaches a file when creates a Question', :js do
    file_name = 'README.md'
    attach_file 'File', "#{Rails.root}/#{file_name}"

    ask_question

    expect(page).to have_link file_name,
        href: "/uploads/attachment/file/1/#{file_name}"
  end
end