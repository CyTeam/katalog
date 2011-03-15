class Role < ActiveRecord::Base
  # change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Associations
  has_and_belongs_to_many :users

  # Helpers
  def to_s
    I18n.translate(name, :scope => 'cancan.roles')
  end
end
