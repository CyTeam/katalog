# encoding: UTF-8

# This class represents the different container types.
class ContainerType < ActiveRecord::Base
  # PaperTrail: change log
  has_paper_trail ignore: [:created_at, :updated_at]

  # Validations
  validates_presence_of :title, :code

  def to_s
    "#{title} (#{code})"
  end
end
