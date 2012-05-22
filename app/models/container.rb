class Container < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:created_at, :updated_at], :meta => {:dossier_id => Proc.new { |container| container.dossier_id }}

  # Associations
  belongs_to :dossier, :touch => true, :inverse_of => :containers
  
  after_save lambda { dossier.touch }
  
  belongs_to :location
  belongs_to :container_type

  # Validations
  validates_presence_of :title, :dossier, :location, :container_type
  
  # Helpers
  def to_s
    "#{dossier.title if dossier.present?} #{period + " " unless period.blank?}(#{container_type.code}@#{location.code})"
  end

  def preorder
    location.preorder
  end

  def container_type=(value)
    value = ContainerType.find_by_code(value) if value.is_a?(String)
    if value.nil?
      self[:container_type_id] = nil
      return
    end
    
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
  
  # Import
  def self.import(row, dossier)
    container = self.create(
      :dossier           => dossier,
      :container_type    => row[3],
      :location          => row[4]
    )

    container.period = extract_period(row[2])
    return container
  end

  def extract_period(title)
    # Try extracting from title by dropping dossier title
    result = title.gsub(/^#{Regexp.escape(dossier.title)}/, '').strip
    return result unless result.blank?

    # Deduce from dossier otherwise
    first_document_year = dossier.first_document_year

    # Guard against some internal dossiers
    return nil if first_document_year.blank?

    return "#{first_document_year} -"
  end
end
