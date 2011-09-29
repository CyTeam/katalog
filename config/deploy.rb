# Airbrake error notification
require 'recipes/rails'
require 'recipes/airbrake'
require './config/boot'
require 'airbrake/capistrano'

#Application
set :application, "katalog"
set :repository,  "git@github.com:CyTeam/katalog.git"

# Staging
set :stages, %w(production staging fallback)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# Deployment
set :server, :passenger
set :user, "deployer"                               # The server's user for deploys

# Configuration
set :scm, :git
ssh_options[:forward_agent] = true
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :copy_exclude, [".git", "spec"]
