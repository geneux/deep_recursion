class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :question, touch: true

  validates :question_id, :user_id, presence: true

  validates :user_id, uniqueness: {scope: :question_id}
end
