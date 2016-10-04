class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true, touch: true

  validates :user_id, presence: true
  validates :body, presence: true, length: (2..2_000)

  default_scope { order(:created_at) }
end
