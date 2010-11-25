class KeywordsController < InheritedResources::Base
  # Association
  optional_belongs_to :dossier
  
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show]
  
  # Responders
  respond_to :html, :js

  # Search
  has_scope :by_character

  # Actions
  def index
    params[:per_page] ||= 25
    params[:search] = {"by_character" => 'A'}.merge(params[:search] || {})
  
    @keywords = apply_scopes(Keyword, params[:search]).order(:name).paginate(:per_page => params[:per_page], :page => params[:page])
    @paginated_scope = Keyword
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

    @keywords = apply_scopes(Keyword, params[:search]).where("name LIKE ?", "%#{@query}%").order(:name).paginate(:per_page => params[:per_page], :page => params[:page])
    @paginated_scope = Keyword.where("name LIKE ?", "%#{@query}%")
    
    render :action => 'index'
  end
end
