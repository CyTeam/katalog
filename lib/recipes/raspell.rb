# encoding: UTF-8

# Generate the aspell wordlist
before 'deploy:restart', 'raspell:generate'
namespace :raspell do
  desc 'Generates the aspell wordlist for the suggestions.'
  task :generate, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} #{bundle_cmd} exec rake katalog:raspell:update"
  end
end
