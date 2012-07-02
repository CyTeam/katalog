# This class is a simple log for authenticated users.
class VisitorLog < ActiveRecord::Base
  # Associations of the visitor log.
  belongs_to :user
  validates_presence_of :user

  # Helper
  def to_s
    title
  end
end
