shared_examples :can_subscribe_unsubscribe do |dir|
  scenario("can #{subscribe_unsubscribe(!dir).downcase}") do
    visit question_path(question)

    expect(page).to have_button subscribe_unsubscribe(dir)
    expect(page).not_to have_button subscribe_unsubscribe(!dir)

    click_button subscribe_unsubscribe(dir)

    expect(page).to have_button subscribe_unsubscribe(!dir)
    expect(page).not_to have_button subscribe_unsubscribe(dir)
  end
end

def subscribe_unsubscribe(dir)
  "#{dir ? 'S' : 'Uns'}ubscribe"
end