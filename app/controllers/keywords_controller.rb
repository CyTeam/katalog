class KeywordsController < InheritedResources::Base
  # Association
  optional_belongs_to :dossier
  
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show]
  
  # Responders
  respond_to :html, :js

  # Actions
  def index
    @keywords = Dossier.keyword_counts.order(:name).paginate(:per_page => params[:per_page], :page => params[:page])
  end
  
  def create
    @dossier = Dossier.find(params[:dossier_id])
    @keywords = @dossier.keyword_list.add(params[:keyword][:name])
    @dossier.save
  end

  def search
    params[:per_page] ||= 25
    
    params[:search] ||= {}
    params[:search][:text] ||= params[:search][:query]

    @query = params[:search][:text]

    @keywords = Dossier.keyword_counts.where("name LIKE ?", "%#{@query}%").order(:name).paginate(:per_page => params[:per_page], :page => params[:page])
    
    render :action => 'index'
  end
end
