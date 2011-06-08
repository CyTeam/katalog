#Application
set :application, "katalog"
set :repository,  "git@github.com:huerlisi/katalog.git"

# Staging
set :stages, %w(production staging)
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

# Restart passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# Bundle install
require "bundler/capistrano"
after "bundle:install", "deploy:migrate"

# Clean up the releases after deploy.
after "deploy", "deploy:cleanup"

# For ts delayed delta
require "delayed/recipes"

# Delayed Job
before "deploy:restart", "delayed_job:stop"
after  "deploy:restart", "delayed_job:start"

after "deploy:stop",  "delayed_job:stop"
after "deploy:start", "delayed_job:start"

