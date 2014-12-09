# encoding: UTF-8

# Generate the aspell wordlist
before 'deploy:restart', 'aspell:generate'
namespace :aspell do
  desc 'Generates the aspell wordlist for the suggestions.'
  task :generate, roles: :app, except: { no_release: true } do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} #{bundle_cmd} exec rake katalog:aspell:update"
  end
end
