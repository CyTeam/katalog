# Settings
# ========
source 'http://rubygems.org'

# Rails
# =====
gem 'rails', '~> 3.0.0'

# Database
gem 'mysql2', '0.2.7'

# Test
# ===
group :test do
  gem 'factory_girl_rails'
  gem 'autotest'
  gem 'autotest-rails'
end

# Development
# ===========
group :development do
  # UML documentation
  gem 'rails-erd'

  # Haml generators
  gem 'hpricot'

  # Deployment
  gem 'capistrano'
  gem 'capistrano-ext'
end
gem 'jquery-rails'

# Standard helpers
# ================
gem 'haml', '3.0.25'
gem 'compass', '~> 0.10.4'
gem 'fancy-buttons'

gem 'formtastic', '~> 1.1.0'
gem 'will_paginate', :git => 'http://github.com/huerlisi/will_paginate.git', :branch => 'rails3'
gem 'inherited_resources'
gem 'has_scope'
gem 'i18n_rails_helpers', '~> 0.9'
gem 'simple-navigation'

# Katalog
# =======
# Authentication
gem 'devise', '~> 1.1'

# Authorization
gem 'cancan'

# Tagging
gem 'acts-as-taggable-on', '~> 2.0.6'

# CRUD helpers
gem 'inherited_resources_views'

# Search
gem 'thinking-sphinx', '~> 2.0.1'
gem 'ts-delayed-delta', :require => 'thinking_sphinx/deltas/delayed_delta'
gem 'delayed_job'

# Reports
#gem 'pdfkit', '~> 0.5'
#gem 'pdfkit', :git => 'http://github.com/huerlisi/PDFKit.git'
#gem 'wkhtmltopdf-binary'
gem 'prawn', :git => "git://github.com/sandal/prawn.git", :tag => '0.10.2', :submodules => true

platforms :ruby_18 do
  # Full text search engine
  gem 'SystemTimer'

  # Import
  gem 'fastercsv'
end

# CRUD helpers
gem 'show_for'

# WYSIWYG Editor
gem 'ckeditor', '3.4.2.pre'

# Change log for model data
gem 'paper_trail'

gem 'revertible_paper_trail', '~> 0.3'

# Generate excel files
gem 'spreadsheet'
