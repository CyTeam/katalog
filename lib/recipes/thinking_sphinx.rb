before "deploy:setup", "ts:setup"
after "deploy:update_code", "ts:symlink"

namespace :ts do
  desc "Create thinking sphinx config"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/config"
    
    logger.info "Creating thinking sphinx configuration"
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
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/#{rails_env}.sphinx.conf #{release_path}/config/#{rails_env}.sphinx.conf"
    run "ln -nfs #{shared_path}/config/sphinx #{release_path}/config/sphinx"
  end

  task :rake, :roles => :app do
    run("cd #{deploy_to}/current && /usr/bin/env rake ts:#{rake_task} RAILS_ENV=#{rails_env}")
  end
  
  desc "Stop sphinx search daemon"
  task :stop, :roles => :app do
    set :rake_task, 'stop'
    rake
  end
  
  desc "Start sphinx search daemon"
  task :start, :roles => :app do
    set :rake_task, 'start'
    rake
  end
  
  desc "Restart sphinx search daemon"
  task :restart, :roles => :app do
    set :rake_task, 'restart'
    rake
  end

  desc "Reindex sphinx search daemon"
  task :reindex, :roles => :app do
    set :rake_task, 'reindex'
    rake
  end
end
