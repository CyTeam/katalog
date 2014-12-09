# encoding: UTF-8

class Container < ActiveRecord::Base
  # change log
  has_paper_trail ignore: [:created_at, :updated_at], meta: { dossier_id: proc(&:dossier_id) }

  # Associations
  belongs_to :dossier, touch: true, inverse_of: :containers

  after_save lambda { dossier.touch }

  belongs_to :location
  attr_accessible :location, :location_code
  belongs_to :container_type
  attr_accessible :container_type, :container_type_code

  # Validations
  validates_presence_of :period, :dossier, :location, :container_type
  attr_accessible :period

  # Helpers
  def to_s
    "#{dossier.title if dossier.present?} #{period + ' ' unless period.blank?}(#{container_type.code}@#{location.code})"
  end

  delegate :preorder, to: :location

  def container_type=(value)
    value = ContainerType.find_by_code(value) if value.is_a?(String)
    if value.nil?
      self[:container_type_id] = nil
      return
    end

    self[:container_type_id] = value.id
    container_type.reload
  end

  def container_type_code
    container_type.try(:code)
  end
  alias_method :container_type_code=, :container_type=

  def location=(value)
    value = Location.find_by_code(value) if value.is_a?(String)
    if value.nil?
      self[:location_id] = nil
    else
      self[:location_id] = value.id
    end
    location.reload unless location.nil?
  end

  def location_code
    location.try(:code)
  end
  alias_method :location_code=, :location=

  def first_document_on=(value)
    dossier.first_document_on = value unless dossier.first_document_on && (value >= dossier.first_document_on)
  end
end
