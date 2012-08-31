FactoryGirl.define do
  sequence :dossier_amount do |n|
    n
  end

  factory :dossier_number do
    association :dossier
    from        Date.new(1900, 1, 1)

    factory :dossier_number_with_amount do
      amount {generate(:dossier_amount)}
    end
  end
end
