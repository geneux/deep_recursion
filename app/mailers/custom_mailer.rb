class CustomMailer < ApplicationMailer

  def digest(user, question_ids)
    @date = Date.yesterday.strftime('%d.%m.%Y')
    @questions = Question.where(id: question_ids)

    mail to: user.email, subject: t('custom_mailer.digest.subject', date: @date)
  end

  def answer(user, answer)
    @answer = answer
    @question = answer.question

    mail to: user.email, subject: t('custom_mailer.answer.subject', topic: @question.topic)
  end
end
