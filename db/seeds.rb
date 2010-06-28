# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Location.create([
  {:code => "EG", :title => "Erdgeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "LE", :title => "Lesesal St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "RI", :title => "Rigistrasse", :address => "Rigistrasse", :availability => "Wünschen Sie ein Dokument von hier, beachten Sie bitte die Wartezeit von einem Tag."},
  {:code => "CO", :title => "Rollgestell St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "SI", :title => "Sitzungszimmer St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "UG", :title => "Untergeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "ML", :title => "Obergeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => ""}
])
