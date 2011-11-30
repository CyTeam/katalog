require 'capones_recipes/cookbook/rails'
require 'capones_recipes/tasks/airbrake'

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

# Bundle install
require "bundler/capistrano"

# Clean up the releases after deploy.
after "deploy", "deploy:cleanup"

# Generate the aspell wordlist
before 'deploy:restart', 'raspell:generate'
namespace :raspell do
  desc 'Generates the aspell wordlist for the suggestions.'
  task :generate, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path} && /usr/bin/env RAILS_ENV=#{rails_env} bundle exec rake katalog:raspell:update"
  end
end

# Plugins
# =======
# Multistaging
require 'capistrano/ext/multistage'
