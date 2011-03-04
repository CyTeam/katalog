before "deploy:setup", "import:setup"
after "deploy:update_code", "import:symlink"

namespace :import do
  desc "Create data directory"
  task :setup, :roles => :import do
    run "mkdir -p #{shared_path}/data"
  end

  desc "Make symlink for data"
  task :symlink, :roles => :import do
    run "ln -nfs #{shared_path}/data #{release_path}/data"
  end

  desc "Upload XLS file"
  task :push, :roles => :import do
    upload "data/Dossier-Katalog.xls", "#{shared_path}/data/dossiers.xls"
    
    run "xls2csv -d utf-8 -c';' #{shared_path}/data/dossiers.xls > #{shared_path}/data/dossiers.csv"
  end  

  task :seed_import_db, :roles => :import do
    old_rails_env = rails_env
    mysql.backup

    set :rails_env, 'import'
    mysql.restore
    
    set :rails_env, old_rails_env
  end

  task :push_import_db, :roles => :import do
    old_rails_env = rails_env
    set :rails_env, 'import'
    mysql.backup

    set :rails_env, old_rails_env
    mysql.restore
  end
  
  task :run, :roles => :import do
    old_rails_env = rails_env
    set :rails_env, 'import'
    
    stream "cd #{deploy_to}/current && RAILS_ENV=#{rails_env} /usr/bin/env bundle exec rails runner 'Dossier.import_from_csv(\"data/dossiers.csv\")'"
    set :rails_env, old_rails_env
  end
  
  task :default do
    push
    seed_import_db
    run
    push_import_db
    ts.reindex
  end
end
