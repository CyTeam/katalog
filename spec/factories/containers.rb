FactoryGirl.define do
  sequence :year do |n|
    2000 + n
  end

  factory :container do
    association :location
    association :container_type
    association :dossier

    factory :container_without_period do
      association :dossier, factory: :dossier_since_1990
    end

    factory :container_with_period do
    end
  end
end
