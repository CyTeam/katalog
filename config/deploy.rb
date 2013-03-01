# encoding: UTF-8

# Application
set :application, 'katalog'
set :repository,  'git@github.com:CyTeam/katalog.git'

require 'capones_recipes/cookbook/rails'
require 'capones_recipes/tasks/settings_logic'
require 'capones_recipes/tasks/thinking_sphinx'
require 'capones_recipes/tasks/email'
require 'capones_recipes/tasks/sync'
require 'capones_recipes/tasks/bluepill'

load 'deploy/assets'

# Staging
set :default_stage, "staging"

# Deployment
set :user, "deployer"                               # The server's user for deploys

# Configuration
set :scm, :git
ssh_options[:forward_agent] = true
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :copy_exclude, [".git", "spec"]

# Clean up the releases after deploy.
after "deploy", "deploy:cleanup"

# Dependencies
depend :remote, :gem, 'bundler', '> 0'
depend :remote, :gem, 'bluepill', ''

# Headers for gem compilation
depend :remote, :deb, "build-essential", ''
depend :remote, :deb, "ruby1.9.1-dev", ''
depend :remote, :deb, "libmysqlclient-dev", ''
depend :remote, :deb, "libxml2-dev", ''
depend :remote, :deb, "libxslt1-dev", ''
depend :remote, :deb, "sphinxsearch", ''
depend :remote, :deb, "imagemagick", ''
depend :remote, :deb, "libaspell-dev", ''
depend :remote, :deb, "aspell-de", ''
