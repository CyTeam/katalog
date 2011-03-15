class Location < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Validations
  validates_presence_of :title, :code, :address, :availability
  
  # Helpers
  def to_s
    "#{title} (#{code})"
  end

  def human_availability
    I18n.translate(availability, :scope => 'katalog.availability.title')
  end

  def self.availabilities
    ['ready', 'wait', 'intern']
  end

  def self.availabilities_for_collection
    self.availabilities.map{|availability| [I18n.translate(availability, :scope => 'katalog.availability.title'), availability]}
  end
end
