Factory.define :container do |f|
  f.association :location
  f.association :container_type
  f.association :dossier
end

Factory.define :container_without_period, :parent => :container do |f|
  f.association :dossier, :factory => :dossier_since_1990
  f.title       {|c| c.dossier.title}
end

Factory.sequence :year do |n|
  2000 + n
end

Factory.define :container_with_period, :parent => :container do |f|
  f.title { "#{Factory.next(:year)} - #{Factory.next(:year)}" }
end
