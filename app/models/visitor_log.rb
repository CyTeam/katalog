# This class is a simple log for authenticated users.
class VisitorLog < ActiveRecord::Base
  # Associations of the visitor log.
  belongs_to :user
  validates_presence_of :user

  # PaperTrail: change log
  has_paper_trail ignore: [:created_at, :updated_at]

  # Helper
  def to_s
    title
  end
end
