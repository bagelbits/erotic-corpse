# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.10'

gem 'rails', '~> 8.1.3'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.7'
# Use Puma as the app server
gem 'puma', '~> 8.0'
# Sprockets is no longer a Rails default; the asset pipeline still serves app/assets.
gem 'sprockets-rails', '~> 3.5'
# dartsass-sprockets replaces sass-rails, whose sassc backend is unmaintained.
gem 'dartsass-sprockets', '~> 3.2'
# Shakapacker is the maintained successor to the retired webpacker gem.
gem 'shakapacker', '~> 10.3'
gem 'haml-rails', '~> 3.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.15'
gem 'jquery-rails', '~> 4.6'
gem 'sidekiq', '~> 8.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.18', require: false

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'rspec-rails', '~> 8.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.10'
  gem 'web-console', '>= 4.2'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'react_on_rails', '~> 17.1'

gem 'bugsnag', '~> 6.30'
