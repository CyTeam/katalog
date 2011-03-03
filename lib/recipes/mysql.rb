namespace :mysql do
  task :backup, :roles => :db, :only => { :primary => true } do
    backup_dir ||= "#{deploy_to}/backups"
    run "mkdir -p #{backup_dir}"

    filename = "#{backup_dir}/#{application}.dump.#{Time.now.to_f}.sql.bz2"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(text)

    on_rollback { run "rm #{filename}" }
    run "mysqldump -u #{yaml[rails_env]['username']} -p #{yaml[rails_env]['database']} -h #{yaml[rails_env]['host']}| bzip2 -c > #{filename}" do |ch, stream, out|
      if out =~ /^Enter password:/
        ch.send_data "#{yaml[rails_env]['password']}\n"
      else
        puts out
      end
    end
    
    run "ln -nfs #{filename} #{backup_dir}/#{application}.latest"
  end

  task :restore, :roles => :db, :only => { :primary => true } do
    backup_dir ||= "#{deploy_to}/backups"

    filename = "#{backup_dir}/#{application}.latest"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(text)

    run "bzip2 -d < #{filename} | mysql -u #{yaml[rails_env]['username']} -p=\"#{yaml[rails_env]['password']}\" #{yaml[rails_env]['database']} -h #{yaml[rails_env]['host']}" do |ch, stream, out|
      if out =~ /^Enter password:/
        ch.send_data "#{yaml[rails_env]['password']}"
      else
        puts out
      end
    end
  end
end
