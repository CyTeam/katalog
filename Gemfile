# Settings
# ========
source 'http://rubygems.org'

# Rails
# =====
gem 'rails'
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
  gem 'capistrano-unicorn', :git => 'git://github.com/sosedoff/capistrano-unicorn.git', :require => false
end
gem 'jquery-rails'

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
gem 'thinking-sphinx'

# Reports
gem 'prawn_rails'
gem 'prawn'

# CRUD helpers
gem 'show_for'

# WYSIWYG Editor
gem "ckeditor"

# Link fixes
gem 'hpricot'
gem 'rails_autolink'

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
  gem 'rack-google-analytics'

  # Performance
  #gem 'newrelic_rpm'

  # Exceptions
  gem 'airbrake'
end
