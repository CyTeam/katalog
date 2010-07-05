class Container < ActiveRecord::Base
  # Associations
  belongs_to :dossier
  belongs_to :location
  belongs_to :container_type
  has_many :numbers, :class_name => 'DossierNumber'
  accepts_nested_attributes_for :numbers

  
end
