# Preview all emails at http://localhost:3000/rails/mailers/custom_mailer
class CustomMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/custom_mailer/digest
  def digest
    raise "No users, cannot create sample" if User.count == 0
    raise "No questions, cannot create sample" if Question.count == 0
    CustomMailer.digest(User.take, Question.limit(5).map(&:id))
  end

  # Preview this email at http://localhost:3000/rails/mailers/custom_mailer/answer
  def answer
    question = Question.joins(:subscriptions, :answers).first
    raise "No subsriptions, cannot create sample" if question.nil?
    CustomMailer.answer(question.user, question.answers.first)
  end
end
