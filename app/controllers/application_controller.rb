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
