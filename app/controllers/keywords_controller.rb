class KeywordsController < InheritedResources::Base
  # Association
  belongs_to :dossier
  
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show]
  
  # Responders
  respond_to :html, :js

  # In Place Edit Actions
  in_place_edit_for 'ActsAsTaggableOn::Tag', :name
end
