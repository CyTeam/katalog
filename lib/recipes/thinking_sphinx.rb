before "deploy:setup", "ts:setup"
after "deploy:update_code", "ts:symlink"

namespace :ts do
  desc "Create thinking sphinx config"
  task :setup do
    run "mkdir -p #{shared_path}/config"
    
    # Load parameters
    db_yml = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(db_yml)
    db_conf = yaml[rails_env]
    
    db_host     = db_conf['host']
    db_user     = db_conf['username']
    db_database = db_conf['database']
    db_socket   = db_conf['socket']
    db_password = db_conf['password']
    
    # Load template
    template = File.read("config/sphinx.conf.example.erb")
    config = ERB.new(template)
    # Write config file
    put config.result(binding), "#{shared_path}/config/#{rails_env}.sphinx.conf"

    run "mkdir -p #{shared_path}/config/sphinx"
  end

  desc "Make symlink for sphinx configs"
  task :symlink do
    run "ln -nfs #{shared_path}/config/#{rails_env}.sphinx.conf #{release_path}/config/#{rails_env}.sphinx.conf"
    run "ln -nfs #{shared_path}/config/sphinx #{release_path}/config/sphinx"
  end
end
