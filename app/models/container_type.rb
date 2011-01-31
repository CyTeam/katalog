class ContainerType < ActiveRecord::Base
  # change log
  has_paper_trail
  # Validations
  validates_presence_of :title, :code
  
  # Helpers
  def to_s
    "#{title} (#{code})"
  end
end
