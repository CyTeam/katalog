class Container < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Associations
  belongs_to :dossier
  belongs_to :location
  belongs_to :container_type

  # Validations
  validates_presence_of :title, :dossier, :location, :container_type
  
  # Helpers
  def to_s
    "#{title} (#{container_type.code}@#{location.code})"
  end

  def container_type=(value)
    value = ContainerType.find_by_code(value) if value.is_a?(String)
    return if value.nil?
    
    self[:container_type_id] = value.id
    self.container_type.reload
  end
  
  def container_type_code
    container_type.try(:code)
  end
  alias container_type_code= container_type=
  
  def location=(value)
    value = Location.find_by_code(value) if value.is_a?(String)
    if value.nil?
      self[:location_id] = nil
    else
      self[:location_id] = value.id
    end
    self.location.reload unless self.location.nil?
  end
  
  def location_code
    location.try(:code)
  end
  alias location_code= location=
  
  def first_document_on=(value)
    dossier.first_document_on = value unless dossier.first_document_on && (value >= dossier.first_document_on)
  end
  
  def period
    return '' if dossier.nil?
    
    result = title.gsub(/^#{dossier.title}/, '').strip
    if result.empty?
      result = "#{dossier.first_document_year} -"
    end
    return result
  end
  
  def period=(value)
    self.title = value
  end
  
  # Import
  def self.import(row, dossier)
    container = self.create(
      :dossier           => dossier,
      :title             => row[1],
      :first_document_on => row[3].nil? ? nil : Date.new(row[3].to_i),
      :container_type    => row[9],
      :location          => row[10]
    )
  end
end
