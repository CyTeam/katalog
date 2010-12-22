Factory.define :container do |f|
  f.association :location
  f.association :container_type
  f.association :dossier
  f.title       {|c| c.dossier.title + ' 1989 -'}
end

Factory.define :container_without_period, :parent => :container do |f|
  f.association :dossier, :factory => :dossier_since_1990
  f.title       {|c| c.dossier.title}
end
