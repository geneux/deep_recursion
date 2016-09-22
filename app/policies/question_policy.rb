class QuestionPolicy < ApplicationPolicy
  include RateablePolicy

  def subscribe?; create?; end
end
