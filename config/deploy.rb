require 'capones_recipes/cookbook/rails'
require 'capones_recipes/tasks/airbrake'
require 'capones_recipes/tasks/thinking_sphinx'

#Application
set :application, 'katalog'
set :repository,  'git@github.com:CyTeam/katalog.git'

# Staging
set :default_stage, "staging"

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

# Clean up the releases after deploy.
after "deploy", "deploy:cleanup"
