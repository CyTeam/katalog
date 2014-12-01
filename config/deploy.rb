# Application
set :application, 'katalog'
set :repository, 'https://github.com/CyTeam/katalog.git'

require 'capones_recipes/cookbook/rails'
require 'capones_recipes/tasks/settings_logic'
require 'capones_recipes/tasks/thinking_sphinx'
require 'capones_recipes/tasks/sync'

load 'deploy/assets'

# Setup rbenv
require 'capistrano-rbenv'
set :rbenv_ruby_version, open(File.expand_path('../../.ruby-version', __FILE__)).read.strip
set :rbenv_setup_shell, false
set :rbenv_install_dependencies, false

# Staging
set :default_stage, 'staging'

# Deployment
set :user, 'deployer'                               # The server's user for deploys

# Configuration
set :scm, :git
set :ssh_options, {:forward_agent => true}
set :use_sudo, false
set :deploy_via, :remote_cache
set :copy_exclude, ['.git', 'spec']

# Clean up the releases after deploy.
after 'deploy', 'deploy:cleanup'

# Dependencies
depend :remote, :gem, 'bundler', '> 0'

# Headers for gem compilation
depend :remote, :deb, 'build-essential', ''
depend :remote, :deb, 'ruby1.9.1-dev', ''
depend :remote, :deb, 'libmysqlclient-dev', ''
depend :remote, :deb, 'libxml2-dev', ''
depend :remote, :deb, 'libxslt1-dev', ''
depend :remote, :deb, 'sphinxsearch', ''
depend :remote, :deb, 'imagemagick', ''
depend :remote, :deb, 'libaspell-dev', ''
depend :remote, :deb, 'aspell-de', ''
