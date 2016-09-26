require "rails_helper"

RSpec.describe CustomMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'digest' do
    let(:questions) { create_list(:question, 2, user: user, created_at: Time.now.yesterday) }
    let(:question_ids) { questions.map(&:id) }
    let(:date) { Date.yesterday.strftime('%d.%m.%Y') }

    let(:mail) { CustomMailer.digest(user, question_ids) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n::t('custom_mailer.digest.subject', date: date))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['e@varnakov.ru'])
    end

    context 'renders the body' do
      subject { mail.body.encoded }

      it('has matched title') { is_expected.to match('Deep Recursion') }
      it('has matched letter type') { is_expected.to match('Digest') }
      it('has matched date') { is_expected.to match(Regexp.quote(date)) }

      it 'matches questions topics and URLs' do
        questions.each do |question|
          is_expected.to match(Regexp.quote(question.topic))
          is_expected.to match(Regexp.quote(url_for(question)))
        end
      end
    end
  end

  describe 'answer' do
    let(:answer_author) { create(:user) }
    let(:question) { create(:question) }
    let(:answer) { create(:answer, user: answer_author, question: question) }

    let(:mail) { CustomMailer.answer(user, answer) }

    it 'renders the headers' do
      expect(mail.subject).to eq(I18n::t('custom_mailer.answer.subject', topic: question.topic))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['e@varnakov.ru'])
    end

    context 'renders the body' do
      subject { mail.body.encoded }

      it('has matched title') { is_expected.to match('Deep Recursion') }
      it('has matched letter type') { is_expected.to match('New Answer to the Question') }

      it('has matched question topic') { is_expected.to match(Regexp.quote(question.topic)) }
      it('has matched question body') { is_expected.to match(Regexp.quote(question.body)) }
      it('has matched question URL') { is_expected.to match(Regexp.quote(url_for(question))) }

      it('has matched answer author email') { is_expected.to match(Regexp.quote(answer_author.email)) }
      it('has matched answer body') { is_expected.to match(Regexp.quote(answer.body)) }
    end
  end
end
