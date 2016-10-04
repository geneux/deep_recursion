source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'pg', '~> 0.15'
gem 'sprockets', '3.6.3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'slim-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'bootstrap-sass', '~> 3.3.6'
gem 'autoprefixer-rails'
gem 'devise'
gem 'faker'
gem 'carrierwave'
gem 'remotipart'
gem 'cocoon'
gem 'private_pub'
gem 'skim'
gem 'gon'
gem 'responders'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'pundit'
gem 'doorkeeper'
gem 'active_model_serializers'
gem 'oj'
gem 'oj_mimic_json'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'whenever'
gem 'dotenv'
gem 'dotenv-deployment', require: 'dotenv/deployment'
gem 'redis-rails'

gem 'mysql2' # Don't worry, it's for Sphinx only!
gem 'thinking-sphinx'

# gem 'unicorn'
gem 'thin'

group :development, :test do
  gem 'byebug', '~>8.0'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'spring-commands-rspec'
  gem 'guard-rspec'

  install_if -> { RUBY_PLATFORM =~ /darwin/ } do
    gem 'rb-fsevent'
  end

  gem 'awesome_print'
  gem 'colorize'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara-webkit'
  gem 'capybara-email'
  gem 'json_spec'
  gem 'test_after_commit'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'meta_request'

  gem 'quiet_assets'

  gem 'rubocop', require: false
  gem 'rails_best_practices'

  gem 'spring'

  gem 'letter_opener'

  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'capistrano3-unicorn', require: false
end

group :production do
  gem 'rack-handlers'
  gem 'unicorn'
end
