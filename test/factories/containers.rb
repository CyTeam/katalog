Factory.define :container do |f|
  f.association :location
  f.association :container_type
  f.association :dossier
  f.title       {|c| c.dossier.title + ' 1989 -'}
end
