class Report < ActiveRecord::Base
  serialize :columns

  validates_uniqueness_of :name
  validates_presence_of :columns
end
