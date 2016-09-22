class MailAnswerJob < ActiveJob::Base
  queue_as :mailers

  def perform(answer)
    Subscription.where(question_id: answer.question_id).find_each do |subscription|
      CustomMailer.answer(subscription.user, answer).deliver_later
    end
  end
end
