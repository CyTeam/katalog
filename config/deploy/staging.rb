set :rails_env, 'staging'
set :branch, "master"

set :deploy_to, '/srv/cyt.ch/katalog'
role :web, "test.doku-zug"                          # Your HTTP server, Apache/etc
role :app, "test.doku-zug"                          # This may be the same as your `Web` server
role :db,  "test.doku-zug", :primary => true        # This is where Rails migrations will run

role :import, "test.doku-zug"
