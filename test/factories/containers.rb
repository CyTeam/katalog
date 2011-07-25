FactoryGirl.define do
  sequence :year do |n|
    2000 + n
  end

  factory :container do
    association :location
    association :container_type
    association :dossier

    factory :container_without_period do
      association :dossier, :factory => :dossier_since_1990
      title       {|c| c.dossier.title}
    end

    factory :container_with_period do
      title { "#{Factory.next(:year)} - #{Factory.next(:year)}" }
    end
  end
end
