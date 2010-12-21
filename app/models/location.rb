class Location < ActiveRecord::Base
  # Validations
  validates_presence_of :title, :code, :address, :availability
  
  # Helpers
  def to_s
    "#{title} (#{code})"
  end
end
