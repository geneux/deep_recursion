require 'rails_helper'
require 'tilt/coffee'
require 'capybara/email/rspec'

RSpec.configure do |config|
  config.include(OmniauthMacros)

  Capybara.javascript_driver = :webkit
  Capybara.default_max_wait_time = 10

  Capybara::Webkit.configure do |config|
    config.block_unknown_urls
  end

  Capybara.server_port = 3001
  Capybara.app_host = 'http://localhost:3001'

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

  config.before(:each, :sphinx) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

OmniAuth.config.test_mode = true
