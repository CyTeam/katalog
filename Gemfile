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
  gem 'sprockets'
  gem 'coffee-rails'
  gem 'therubyracer'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'fancy-buttons'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Test
# ===
group :test do
  # Matchers/Helpers
  gem 'shoulda'

  # Mocking
  # gem 'mocha'

  # Browser
  gem 'webrat'
end

group :test, :development do
  # Framework
  gem 'rspec-rails'

  # Fixtures
  gem 'factory_girl_rails'
  gem 'database_cleaner'

  # Browser
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'

  # Console
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-debugger'
end

# Development
# ===========
group :development do
  # RDoc
  gem 'rdoc'

  # UML documentation
  gem 'rails-erd'

  # Deployment
  gem 'capistrano', '~> 2.15.5'
  gem 'capones_recipes'

  # Development Server
  gem 'webrick'
  gem 'quiet_assets'
end

# Standard helpers
# ================
gem 'haml'

gem 'formtastic'
gem 'will_paginate', :git => 'https://github.com/huerlisi/will_paginate.git', :branch => 'show_always'
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
gem 'thinking-sphinx', '~> 2.1.0'

# Reports
gem 'prawn_rails'
gem 'prawn'

# CRUD helpers
gem 'show_for'

# WYSIWYG Editor
gem "ckeditor"

# Link fixes
gem 'rails_autolink'
gem 'hpricot'

# Change log for model data
gem 'paper_trail'

gem 'revertible_paper_trail'

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
  gem 'rack-google-analytics', :git => 'http://github.com/huerlisi/rack-google-analytics'

  # Performance
  #gem 'newrelic_rpm'

  # Exceptions
  gem 'airbrake'
end
