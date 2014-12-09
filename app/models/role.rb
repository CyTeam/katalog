# encoding: UTF-8

class Role < ActiveRecord::Base
  # PaperTrail: change log
  has_paper_trail ignore: [:created_at, :updated_at]

  # Associations
  has_and_belongs_to_many :users

  def to_s
    I18n.translate(name, scope: 'cancan.roles')
  end
end
