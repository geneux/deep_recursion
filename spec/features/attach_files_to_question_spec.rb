require 'features_helper'

feature 'Attach files to Question', %q(
  To provide extra data
  As a Question author
  I want to attach files to the Question
) do
  given(:user) { create(:user) }

  background do
    sign_in user
    visit new_question_path
  end

  scenario 'User attaches a file when creates a Question' do
    file_name = 'README.md'
    fill_in 'Question topic:', with: Faker::Lorem.sentence
    fill_in 'Question:', with: Faker::Lorem.paragraph(4, true, 8)
    attach_file 'File', "#{Rails.root}/#{file_name}"
    click_on 'Ask Question'

    expect(page).to have_link file_name,
        href: "/uploads/attachment/file/1/#{file_name}"
  end
end