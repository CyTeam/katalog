before "deploy:setup", "import:setup"
after "deploy:update_code", "import:symlink"

namespace :import do
  desc "Create data directory"
  task :setup do
    run "mkdir -p #{shared_path}/data"
  end

  desc "Make symlink for data"
  task :symlink do
    run "ln -nfs #{shared_path}/data #{release_path}/data"
  end

  desc "Upload XLS file"
  task :push do
    run "mkdir -p #{shared_path}/data"
    upload "data/Dossier-Katalog.xls", "#{shared_path}/data/dossiers.xls", :via => :scp
    
    run "xls2csv -d utf-8 -c';' #{shared_path}/data/dossiers.xls > #{shared_path}/data/dossiers.csv"
  end  

  task :seed_db do
    set :rails_env, 'production'
    mysql.backup

    set :rails_env, 'import'
    mysql.restore
  end
end
