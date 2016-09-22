class MailDigestJob < ActiveJob::Base
  queue_as :mailers

  def perform
    question_ids = Question.where(created_at: Time.now.yesterday.all_day).order(created_at: :desc).map(&:id)

    User.find_each do |user|
      CustomMailer.digest(user, question_ids).deliver_later
    end
  end
end
