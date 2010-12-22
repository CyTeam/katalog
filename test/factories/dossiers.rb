Factory.define :dossier do |f|
  f.signature     '11.1.111'
  f.title         'Dossier 1'
  f.new_signature '11.111.1'
end

Factory.define :dossier_since_1990, :parent => :dossier do |f|
  f.first_document_on '1990-01-01'
end
