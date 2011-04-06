# This class defines different views on the dossiers.
class Report < ActiveRecord::Base

  # Serializes the column attribute.
  serialize :columns

  # Associations
  validates_uniqueness_of :name
  validates_presence_of :columns
end
