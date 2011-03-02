set :deploy_to, '/srv/cyt.ch/katalog'
set :branch, "stable"
role :web, "web01.doku-zug"                          # Your HTTP server, Apache/etc
role :app, "web01.doku-zug"                          # This may be the same as your `Web` server
role :db,  "web01.doku-zug", :primary => true        # This is where Rails migrations will run
