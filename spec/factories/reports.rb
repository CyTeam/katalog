FactoryGirl.define do
  factory :report do
    name 'simple'
    title 'Simple Report'
    columns [:signature, :title, :document_count]
    years_visible true
  end
end
