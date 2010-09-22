class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def self.in_place_edit_for(object, attribute, options = {})
    define_method("set_#{attribute}") do
      unless [:post, :put].include?(request.method_symbol) then
        return render(:text => 'Method not exactly allowed', :status => 405)
      end
      @item = object.to_s.camelize.constantize.find(params[:id])
      @item.update_attribute(attribute, params[:value])
      render :text => CGI::escapeHTML(@item.send(attribute).to_s)
    end
  end

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
