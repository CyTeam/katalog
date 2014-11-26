namespace :katalog do
  desc 'Create sphinx wordform and exception lists.'
  task :export_sphinx_lists, roles: :app do
    logger.info 'Create sphinx wordform and exception lists.'
    run "cd #{deploy_to}/current && RAILS_ENV=#{rails_env} /usr/bin/env bundle exec rails runner 'SphinxAdminWordForm.send(:export_file); SphinxAdminException.send(:export_file)'"
  end
end
