require 'paper_trail/version'

ActiveRecord::Base.class_eval do
  def id_attributes
    attributes.select {|a, b| a.end_with?'id' and not a.eql?'id' }
  end
end

Version.class_eval do
  attr_accessible :dossier_id, :number_ids, :container_ids
end
