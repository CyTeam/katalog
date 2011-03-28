# MySQL Backup/Restore tasks
#
# Based on code from:
# * http://snippets.aktagon.com/snippets/20-Capistrano-2-task-for-backing-up-your-MySQL-production-database-before-each-deployment
# * http://www.martin-probst.com/blog/2007/11/20/mysql-backup-restore-task-for-capistrano/

namespace :mysql do
  task :backup, :roles => :import do
    backup_dir ||= "#{deploy_to}/backups"
    run "mkdir -p #{backup_dir}"

    filename = "#{backup_dir}/#{application}.dump.#{Time.now.strftime('%Y-%m-%d_%H-%M')}.sql.bz2"
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

  task :restore, :roles => :import do
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

  namespace :sync do
    desc "Sync down the mysql db to local"
    task :down do
      sync_dir ||= "#{deploy_to}/sync"
      run "mkdir -p #{sync_dir}"

      filename = "#{application}.dump.#{Time.now.strftime('%Y-%m-%d_%H-%M')}.sql.bz2"
      text = capture "cat #{deploy_to}/current/config/database.yml"
      yaml = YAML::load(text)
      on_rollback { delete filename }

      # Remote DB dump
      run "mysqldump -u #{yaml[rails_env]['username']} -p #{yaml[rails_env]['database']} -h #{yaml[rails_env]['host']} | bzip2 -9 > #{sync_dir}/#{filename}" do |channel, stream, data|
        if data =~ /^Enter password:/
          channel.send_data "#{yaml[rails_env]['password']}\n"
        else
          puts data
        end
      end

      # Download dump
      download "#{sync_dir}/#{filename}", filename

      run "rm #{sync_dir}/#{filename}"

      # Local DB import
      username, password, database = database_config('development')
      system "bzip2 -d -c #{filename} | mysql -u #{username} --password='#{password}' #{database}; rm -f #{filename}"
      system "rake db:migrate"

      logger.important "sync database from the stage '#{stage}' to local finished"
    end

    #
    # Reads the database credentials from the local config/database.yml file
    # +db+ the name of the environment to get the credentials for
    # Returns username, password, database
    #
    def database_config(db)
      database = YAML::load_file('config/database.yml')
      return database["#{db}"]['username'], database["#{db}"]['password'], database["#{db}"]['database']
    end
  end

end
