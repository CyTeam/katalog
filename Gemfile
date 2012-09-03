# Settings
# ========
source 'http://rubygems.org'

# Rails
# =====
gem 'rails', '~> 3.2.8'

# Database
gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'sprockets'
  gem 'coffee-rails'
  gem 'therubyracer'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'fancy-buttons'
end


# Test
# ===
group :test do
  # Matchers/Helpers
  gem 'shoulda'

  # Mocking
  # gem 'mocha'

  # Browser
  gem 'capybara'
  gem 'webrat'

  # Autotest
  gem 'autotest'
  gem 'autotest-rails'
end

group :test, :development do
  # Framework
  # gem "rspec"
  # gem 'rspec-rails'

  # Fixtures
  gem 'factory_girl_rails'

  # Integration
  # gem 'cucumber-rails'
  # gem 'cucumber'
end

# Development
# ===========
group :development do
  # RDoc
  gem 'rdoc'

  # UML documentation
  gem 'rails-erd'

  # Haml generators
  gem 'hpricot'

  # Deployment
  gem 'capones_recipes'
end
gem 'jquery-rails'

# Standard helpers
# ================
gem 'haml'

gem 'formtastic'
gem 'will_paginate'
gem 'inherited_resources'
gem 'has_scope'
gem 'i18n_rails_helpers'
gem 'simple-navigation'

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

# Reports
gem 'prawn_rails'
gem 'prawn'

platforms :ruby_18 do
  # Full text search engine
  gem 'SystemTimer'

  # Import
  gem 'fastercsv'
end

# CRUD helpers
gem 'show_for'

# WYSIWYG Editor
gem "ckeditor"

# Link fixes
gem 'hpricot'

# Change log for model data
gem 'paper_trail'

gem 'revertible_paper_trail', :path => "../revertible_paper_trail"

# Generate excel files
gem 'spreadsheet'

# Spellchecking
gem 'raspell', :git => 'http://github.com/huerlisi/raspell.git'

# Squeel
gem "squeel"

# Monitoring
# ==========
gem 'settingslogic'
group :staging, :production do
  # Traffic
  gem 'rack-google_analytics'

  # Performance
  #gem 'newrelic_rpm'

  # Exceptions
  gem 'airbrake'
end
