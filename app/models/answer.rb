class Answer < ActiveRecord::Base
  include Rateable
  include Commentable

  belongs_to :user
  belongs_to :question
  has_many :attachments, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, reject_if: :all_blank

  validates :user_id, :question_id, presence: true
  validates :body, presence: true, length: (20..50_000)

  after_commit :invoke_subscriptions_delivery, on: :create

  def star!
    question.transaction do
      question.answers.where(starred: true).update_all(starred: false)
      update!(starred: true)
    end
  end

  def invoke_subscriptions_delivery
    MailAnswerJob.perform_later(self)
  end
end
