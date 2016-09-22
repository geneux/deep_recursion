require 'rails_helper'

describe MailAnswerJob do
  let(:user) { create(:user) }
  let(:alt_user) { create(:user) }
  let(:question) { create(:question, user: alt_user) }
  let!(:subscription) { create(:subscription, user: user, question: question) }
  let(:answer) { create(:answer, question: question) }
  let(:message) { double(CustomMailer.delay) }

  it 'should send new Answer notifications for both User and question author' do
    [user, alt_user].each do |u|
      expect(CustomMailer).to receive(:answer).with(u, answer).and_return(message)
      expect(message).to receive(:deliver_later)
    end
    MailAnswerJob.perform_now(answer)
  end

  it_behaves_like(:delayed_job) { let(:args) { answer } }
end
