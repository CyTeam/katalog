set :rails_env, 'production'
set :branch, "stable"

set :deploy_to, '/srv/cyt.ch/katalog'
role :web, "web01.doku-zug"                          # Your HTTP server, Apache/etc
role :app, "web01.doku-zug"                          # This may be the same as your `Web` server
role :db,  "web01.doku-zug", :primary => true        # This is where Rails migrations will run
role :import, "test.doku-zug"
