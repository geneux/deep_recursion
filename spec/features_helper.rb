require 'rails_helper'
require 'tilt/coffee'

RSpec.configure do |config|
  Capybara.javascript_driver = :webkit
  Capybara.default_max_wait_time = 4

  Capybara::Webkit.configure do |config|
    config.block_unknown_urls
  end

  config.include FeaturesMacros, type: :feature

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

class Counter
  class << self
    def set(val)
      @val = val
    end

    def inc
      @val ||= 0
      @val += 1
    end

    def val
      @val ||= 0
    end
  end
end