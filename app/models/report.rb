class Report < ActiveRecord::Base
  serialize :columns

  validates_uniqueness_of :name
end
