before "deploy:setup", "ts:setup"
after "deploy:update_code", "ts:symlink"

namespace :ts do
  desc "Create thinking sphinx config"
  task :setup do
    run "mkdir -p #{shared_path}/config"
    upload "config/development.sphinx.conf.example", "#{shared_path}/config/production.sphinx.conf", :via => :scp

    run "mkdir -p #{shared_path}/config/sphinx"
  end

  desc "Make symlink for sphinx configs"
  task :symlink do
    run "ln -nfs #{shared_path}/config/production.sphinx.conf #{release_path}/config/production.sphinx.conf"
    run "ln -nfs #{shared_path}/config/sphinx #{release_path}/config/sphinx"
  end
end
