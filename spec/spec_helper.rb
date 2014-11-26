# encoding: UTF-8

require 'rubygems'

ENV['RAILS_ENV'] = 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# Capybara
require 'capybara/rails'

Capybara.configure do |config|
  config.default_driver    = :rack_test

  # Evaluate javascript driver
  js_driver = (ENV['JS_DRIVER'] || :poltergeist).to_sym

  # Alias :phantomjs to :poltergeist
  js_driver = :poltergeist if js_driver == :phantomjs

  if js_driver == :poltergeist
    require 'capybara/poltergeist'
  end
  config.javascript_driver = js_driver
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# TODO: not sure why this is needed, it's not using the default locale otherwise
I18n.locale = 'de-CH'

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Increase log level on CI
  if ENV['CI'] || ENV['TRAVIS']
    Rails.logger.level = 4
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true
  # config.use_transactional_examples = true

  require 'database_cleaner'

  config.use_transactional_fixtures                      = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
