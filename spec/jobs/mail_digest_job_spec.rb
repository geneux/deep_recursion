require 'rails_helper'

describe MailDigestJob do
  let(:users) { create_list(:user, 2) }
  let(:question_ids) { create_list(:question, 2, user: users.first, created_at: Time.now.yesterday).map(&:id) }
  let(:message) { double(CustomMailer.delay) }

  it 'should send daily digest to all users' do
    users.each do |user|
      expect(CustomMailer).to receive(:digest).with(user, question_ids).and_return(message)
      expect(message).to receive(:deliver_later)
    end
    MailDigestJob.perform_now
  end

  it_behaves_like(:delayed_job) { let(:args) {} }
end
