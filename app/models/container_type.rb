class ContainerType < ActiveRecord::Base
  # Validations
  validates_presence_of :title, :code
  
  # Helpers
  def to_s
    "#{title} (#{code})"
  end
end
