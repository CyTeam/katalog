# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Location.create!([
  {:code => "EG", :title => "Erdgeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "LE", :title => "Lesesaal St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "RI", :title => "Rigistrasse", :address => "Rigistrasse", :availability => "Wünschen Sie ein Dokument von hier, beachten Sie bitte die Wartezeit von einem Tag."},
  {:code => "CO", :title => "Rollgestell St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "SI", :title => "Sitzungszimmer St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "UG", :title => "Untergeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => "Diese Dokumente sind bei uns sofort einsehbar."},
  {:code => "ML", :title => "Obergeschoss St. Oswaldsgasse 16", :address => "St. Oswaldsgasse 16", :availability => ""}
])

ContainerType.create!([
  {:code => "DH",    :title => "Dossier in Hängemappe", :description => "Die Sammlung der aktuellsten Artikel zu diesem Thema finden Sie in einem Hängemäppchen."},
  {:code => "DHBro", :title => "Broschüre in Dossier",  :description => "Diese Broschüre ist im dazupassenden Dossier abgelegt. Beachten Sie die Jahreszahl."},
  {:code => "DA",    :title => "Dossier in Archivbox",  :description => "Die Sammlung der älteren Artikel zum Thema finden sie in Archivschachteln."},
  {:code => "B",     :title => "Buch"},
  {:code => "V",     :title => "Video"},
  {:code => "DO",    :title => "Dossier in Ordner",     :description => "Die Artikel zu diesem Thema haben wir in einem Ordner abgelegt."},
  {:code => "O",     :title => "Ordner"},
  {:code => "Z",     :title => "Zeitschrift"},
  {:code => "CDR",   :title => "CDROM"},
  {:code => "CD",    :title => "CD"},
  {:code => "Disk",  :title => "Diskette"}
])

Role.create!([
  {:name => 'admin'},
  {:name => 'editor'}
])