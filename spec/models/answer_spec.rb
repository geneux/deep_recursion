require 'rails_helper'

describe Answer do
  it { is_expected.to belong_to :question }

  it { is_expected.to validate_presence_of :question_id }
  it { is_expected.to validate_presence_of :body }

  it { is_expected.to validate_length_of(:body).is_at_least(20) }
  it { is_expected.to validate_length_of(:body).is_at_most(50_000) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :question_id }

  describe '#star!' do
    it 'should star the selected answer' do
      question = create(:question)
      answer1 = create(:answer, question: question)
      answer2 = create(:answer, question: question, starred: true)
      answer3 = create(:answer, question: question)
      question.save!
      answer3.star!
      expect(answer1.reload.starred).to eq(false)
      expect(answer2.reload.starred).to eq(false)
      expect(answer3.reload.starred).to eq(true)
    end
  end

  describe '#invoke_subscriptions_delivery' do
    let(:answer) { build(:answer) }
    it 'should invoke MailAnswerJob' do
      expect(MailAnswerJob).to receive(:perform_later).with(answer)
      answer.save!
    end
  end

  it_behaves_like :user_related
  it_behaves_like :attachable

  it_behaves_like :rateable do
    let (:rateable) { create(:answer, user: user) }
  end
end
