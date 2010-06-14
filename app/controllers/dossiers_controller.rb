require 'ostruct'

class DossiersController < InheritedResources::Base
  # Responders
  respond_to :html, :js
  
  # Search
  has_scope :by_signature, :as => :signature
  has_scope :by_title, :as => :title
  has_scope :by_location, :as => :location
  has_scope :by_kind, :as => :kind
  
  # Tags
  has_scope :tagged_with, :as => :tag
  
  # GET /dossiers
  # GET /dossiers.xml
  def index
    params[:dossier] ||= {}
    @dossiers = apply_scopes(Dossier, params[:dossier]).paginate :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dossiers }
    end
  end

  # GET /dossiers/search
  # GET /dossiers/search.xml
  def search
    params[:dossier] ||= {}
    @dossiers = apply_scopes(Dossier, params[:dossier]).paginate :page => params[:page]

    respond_to do |format|
      format.html # search.html.erb
      format.xml  { render :xml => @dossiers }
    end
  end
end
