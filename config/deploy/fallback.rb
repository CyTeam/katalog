set :rails_env, 'fallback'
set :branch, "stable"

set :deploy_to, '/srv/doku-zug.ch/katalog'
role :web, "web02.doku-zug"                          # Your HTTP server, Apache/etc
role :app, "web02.doku-zug"                          # This may be the same as your `Web` server
role :db,  "web02.doku-zug", :primary => true        # This is where Rails migrations will run
role :import, "web02.doku-zug"
