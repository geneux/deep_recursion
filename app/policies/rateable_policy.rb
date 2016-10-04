module RateablePolicy
  def rate?
    admin? || user? && !owner?
  end
end
