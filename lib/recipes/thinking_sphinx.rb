# Thinking Sphinx for Capistrano
require 'thinking_sphinx/deploy/capistrano'

after "deploy:setup", "thinking_sphinx:setup"

after "deploy:migrate" do
  thinking_sphinx.symlink
  thinking_sphinx.rebuild
end

namespace :thinking_sphinx do
  desc "Prepare for sphinx config"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/config/sphinx"
    run "mkdir -p #{shared_path}/db/sphinx"
  end

  desc "Make symlink for sphinx configs and data"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/sphinx #{release_path}/config/sphinx"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
end
