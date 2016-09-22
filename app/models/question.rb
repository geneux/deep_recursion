class Question < ActiveRecord::Base
  include Rateable
  include Commentable

  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  accepts_nested_attributes_for :attachments, reject_if: :all_blank

  validates :user_id, presence: true
  validates :topic, presence: true, length: (10..200)
  validates :body, presence: true, length: (20..50_000)

  after_create :subscribe_author!

  private

  def subscribe_author!
    subscriptions.create!(user_id: user_id)
  end
end
