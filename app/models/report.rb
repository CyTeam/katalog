class Report < ActiveRecord::Base
  serialize :column_names

  validates :name, :title, :column_names, presence: true
  validates :name, uniqueness: true

  before_save :default_collect_year_count

  def default_collect_year_count
    self.collect_year_count = 1 if collect_year_count.blank? && years_visible?
  end

  def to_s
    "#{self.class}: #{name}"
  end
end
