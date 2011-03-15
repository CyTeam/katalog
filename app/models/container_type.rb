class ContainerType < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Validations
  validates_presence_of :title, :code
  
  # Helpers
  def to_s
    "#{title} (#{code})"
  end
end
