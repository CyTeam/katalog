require 'paper_trail/version'

Version.class_eval do
  default_scope :order => 'created_at DESC'
end