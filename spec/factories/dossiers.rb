FactoryGirl.define do
  factory :dossier do
    signature '11.1.111'
    title 'Dossier 1'

    factory :dossier_since_1990 do
      first_document_on '1990-01-01'
    end
  end
end
