# Settings
# ========
source 'https://rubygems.org'

# Rails
# =====
gem 'rails'
# Database
# ========
gem 'mysql2'

# Journaling
# ==========
gem 'paper_trail'

# Asset Pipeline
# ==============
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'therubyracer', platforms: :ruby
gem 'quiet_assets'
gem 'compass-rails'

# CRUD
# ====
gem 'inherited_resources', '~> 1.5.0' # Dependency on has_scope release candidate
gem 'jbuilder'
gem 'has_scope'
gem 'show_for'
gem 'will_paginate'
gem 'nokogiri'
gem 'holidays'

# I18n
# ====
gem 'i18n_rails_helpers', github: 'huerlisi/i18n_rails_helpers'

# UI
# ==
gem 'simple-navigation'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'formtastic'

# WYSIWYG Editor
# ==============
gem 'ckeditor'

# Model extensions
# =============
gem 'acts-as-taggable-on'

# Search
# ======
gem 'thinking-sphinx'

# Spellchecking
# =============
gem 'ffi-aspell'

# PDF reports
# ===========
gem 'prawn_rails'
gem 'prawn'
gem 'prawn-table'

# Generate excel files
# ====================
gem 'spreadsheet'

# Page fetcher
# ============
gem 'mechanize'

# Docs
# ====
group :doc do
  # Docs
  gem 'sdoc', require: false
end

# Access Control
# ==============
gem 'devise'
gem 'cancancan'

# Deployment
# ==========
gem 'unicorn-rails'

# Exception Notifier
# ==================
gem 'airbrake'

# Profiling
# =========
gem 'rack-google-analytics'

# Application settings
# ====================
gem 'settingslogic'

group :development do
  # Generators
  gem 'haml-rails'

  # Debugging
  gem 'better_errors'
  gem 'binding_of_caller'  # Needed by binding_of_caller to enable html console

  # Deployment
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'
  #gem 'capones_recipes'
end

group :development, :test do
  # (Pre-)loading
  gem 'spring'
  gem 'spring-commands-rspec'

  # Testing Framework
  gem 'rspec-rails'

  # Matchers/Helpers
  gem 'shoulda'

  # QA
  gem 'simplecov', require: false
  gem 'rubocop', require: false

  # Debugger
  gem 'pry-rails'
  gem 'pry-byebug'

  # Fixtures
  gem 'factory_girl_rails'
end
