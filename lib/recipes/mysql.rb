# MySQL Backup/Restore tasks
#
# Based on code from:
# * http://snippets.aktagon.com/snippets/20-Capistrano-2-task-for-backing-up-your-MySQL-production-database-before-each-deployment
# * http://www.martin-probst.com/blog/2007/11/20/mysql-backup-restore-task-for-capistrano/

namespace :mysql do
  task :backup, :roles => :db, :only => { :primary => true } do
    backup_dir ||= "#{deploy_to}/backups"
    run "mkdir -p #{backup_dir}"

    filename = "#{backup_dir}/#{application}.dump.#{Time.now.to_f}.sql.bz2"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(text)

    on_rollback { run "rm #{filename}" }

    logger.info "Backing up to #{filename}..."
    run "mysqldump -u #{yaml[rails_env]['username']} -p #{yaml[rails_env]['database']} -h #{yaml[rails_env]['host']}| bzip2 -c > #{filename}" do |ch, stream, out|
      if out =~ /^Enter password:/
        ch.send_data "#{yaml[rails_env]['password']}\n"
      else
        puts out
      end
    end
    
    run "ln -nfs #{filename} #{backup_dir}/#{application}.latest"
    
    logger.info "Backup successfull."
  end

  task :restore, :roles => :db, :only => { :primary => true } do
    backup_dir ||= "#{deploy_to}/backups"

    filename = "#{backup_dir}/#{application}.latest"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(text)

    logger.info "Restoring from #{filename}..."
    run "bzip2 -d < #{filename} |mysql -u #{yaml[rails_env]['username']} -p#{yaml[rails_env]['password']} -h #{yaml[rails_env]['host']} #{yaml[rails_env]['database']}" do |ch, stream, out|
      puts out
    end
    
    logger.info "Restore successfull."
  end
end
