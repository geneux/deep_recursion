class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :attachments, dependent: :destroy

  accepts_nested_attributes_for :attachments

  validates :user_id, presence: true
  validates :topic, presence: true, length: (10..200)
  validates :body, presence: true, length: (20..50_000)
end
