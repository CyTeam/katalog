# encoding: UTF-8

# This class represents the different locations where a container can be stored.
class Location < ActiveRecord::Base
  # Associations
  has_many :containers
  has_many :dossiers, through: :containers

  # PaperTrail: change log
  has_paper_trail ignore: [:created_at, :updated_at]

  # Validations
  validates_presence_of :title, :code, :address, :availability

  def to_s
    "#{title} (#{code})"
  end

  # Returns the availability of the location translated with I18n.
  #
  # * The translations are under 'katalog.availability.title'
  def human_availability
    I18n.translate(availability, scope: 'katalog.availability.title')
  end

  # Returns the states of the availability.
  def self.availabilities
    %w(ready wait intern)
  end

  # Returns the availabilities as collection.
  #
  # * For use in forms
  def self.availabilities_for_collection
    availabilities.map { |availability| [I18n.translate(availability, scope: 'katalog.availability.title'), availability] }
  end
end
