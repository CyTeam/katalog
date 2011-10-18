# This class defines different views on the dossiers.
class Report < ActiveRecord::Base

  # Serializes the column attribute.
  serialize :columns

  # Validations
  validates :name,    :presence => true, :uniqueness => true
  validates :columns, :presence => true
  validates :title,   :presence => true
end
