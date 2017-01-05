# Settings
# ========
source 'http://rubygems.org'

# Rails
# =====
gem 'rails'

# Unicorn
# =======
gem 'unicorn'

# Database
gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'therubyracer'
  gem 'uglifier'
  gem 'compass-rails'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Test
# ===
group :test do
  # Matchers/Helpers
  gem 'shoulda'
end

group :test, :development do
  # Framework
  gem 'rspec-rails'

  # Fixtures
  gem 'factory_girl_rails'
  gem 'database_cleaner'

  # Debugger
  gem 'pry-rails'
  gem 'pry-byebug'
end

# Development
# ===========
group :development do
  # RDoc
  gem 'rdoc'

  # Deployment
  gem 'capistrano', '~> 2.15.5'
  gem 'capistrano-rbenv', '~> 1.0'
  gem 'capones_recipes'

  gem 'quiet_assets'

  # Code quality
  gem 'rubocop', require: false
end

# Standard helpers
# ================
gem 'haml-rails'

gem 'formtastic'
gem 'will_paginate', git: 'https://github.com/huerlisi/will_paginate.git', branch: 'show_always'
gem 'inherited_resources'
gem 'has_scope'
gem 'i18n_rails_helpers'
gem 'simple-navigation'
gem 'nokogiri'
# Katalog
# =======
# Authentication
gem 'devise'

# Authorization
gem 'cancan'

# Tagging
gem 'acts-as-taggable-on'

# Search
gem 'thinking-sphinx'

# Spellchecking
gem 'ffi-aspell'

# Reports
gem 'prawn_rails'
gem 'prawn'
gem 'prawn-table'

# CRUD helpers
gem 'show_for'

# WYSIWYG Editor
gem 'ckeditor'

# Change log for model data
gem 'paper_trail'

gem 'revertible_paper_trail'

# Generate excel files
gem 'spreadsheet'

# Load html content
gem 'mechanize'

# Date handling
gem 'holidays'

# Monitoring
# ==========
gem 'settingslogic'
group :staging, :production do
  # Traffic
  gem 'rack-google-analytics'

  # Exceptions
  gem 'airbrake'
end
