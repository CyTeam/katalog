class Container < ActiveRecord::Base
  # Associations
  belongs_to :dossier
  belongs_to :location
  belongs_to :container_type
  has_many :numbers, :class_name => 'DossierNumber'
  accepts_nested_attributes_for :numbers

  # Helpers
  def to_s
    "#{title} (#{container_type.code}@#{location.code})"
  end

  def title
    dossier.title
  end

  def container_type=(value)
    value = ContainerType.find_by_code(value) if value.is_a?(String)
    self[:container_type_id] = value.id
    self.container_type.reload
  end
  
  def location=(value)
    value = Location.find_by_code(value) if value.is_a?(String)
    self[:location_id] = value.id
    self.location.reload
  end
  
  # Import
  def import(row)
    container = self.create(
      :document_type => row[9],
      :location      => row[10]
    )
  end
end
