# Settings
# ========
source 'http://rubygems.org'

# Rails
# =====
gem 'rails', '~> 3.0.11'

# Database
gem 'mysql2', '~> 0.2.6'

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

  # MySQL Query Analyzer
  gem 'query_reviewer'
end
gem 'jquery-rails'

# Standard helpers
# ================
gem 'haml'
gem 'compass'
gem 'fancy-buttons'

gem 'formtastic'
gem 'will_paginate', :git => 'http://github.com/huerlisi/will_paginate.git', :branch => 'rails3'
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
gem 'acts-as-taggable-on', '2.0.6'

# CRUD helpers
gem 'inherited_resources_views'

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
gem 'ckeditor', :git => 'http://github.com/pshoukry/ckeditor.git' # This repo has a pending pull request to ckeditor when integrated the git path could be removed.
# Link fixes
gem 'hpricot'

# Change log for model data
gem 'paper_trail'

gem 'revertible_paper_trail'

# Generate excel files
gem 'spreadsheet'

# Spellchecking
gem 'raspell'

# Error notifier
gem 'airbrake'

# MetaWhere
gem 'meta_where'

# Monitoring
group :production do
  gem 'rack-google_analytics', :require => "rack/google_analytics", :git => 'git://github.com/ambethia/rack-google_analytics.git'
end
