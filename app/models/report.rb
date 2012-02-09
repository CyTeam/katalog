# This class defines different views on the dossiers.
class Report < ActiveRecord::Base

  # Serializes the column attribute.
  serialize :columns

  # Validations
  validates :name,    :presence => true, :uniqueness => true
  validates :columns, :presence => true
  validates :title,   :presence => true

  before_save :default_collect_year_count

  def default_collect_year_count
    self.collect_year_count = 1 if (collect_year_count.blank? and years_visible?)
  end

  def to_s
    "#{self.class}: #{name}"
  end
end
