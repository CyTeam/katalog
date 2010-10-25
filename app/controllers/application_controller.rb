class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
end

# Ugly monkey patching acts_as_taggable to trigger reindexing
ActsAsTaggableOn::Tag
class ActsAsTaggableOn::Tag
  after_save :touch_taggings
  after_destroy :touch_taggings
  
  private
  def touch_taggings
    taggings.map{|t| t.save}
  end
end

ActsAsTaggableOn::Tagging
class ActsAsTaggableOn::Tagging
  after_save :set_dossier_delta_flag
  
  private
  def set_dossier_delta_flag
    return if taggable.changed?
    
    if taggable.is_a? Dossier
      taggable.delta = true
      taggable.save
    end
  end
end
