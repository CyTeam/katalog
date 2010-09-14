Factory.define :dossier_number do |f|
  f.association :dossier
end

Factory.sequence :dossier_amount do |n|
  n
end

Factory.define :dossier_number_with_amount, :parent => :dossier_number do |f|
  f.amount      {Factory.next :dossier_amount}
end
