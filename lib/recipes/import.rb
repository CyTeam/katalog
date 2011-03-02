namespace :import do
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
