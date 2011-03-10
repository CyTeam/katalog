require 'paper_trail/version'

Version.class_eval do
  default_scope :order => 'created_at DESC'
end

ActiveRecord::Base.class_eval do
  def id_attributes
    attributes.select {|a, b| a.end_with?'id' and not a.eql?'id' }
  end
end
