class KeywordsController < InheritedResources::Base
  # Association
  optional_belongs_to :dossier
  
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :suggestions, :search, :show]
  
  # Responders
  respond_to :html, :js, :json

  # Search
  has_scope :by_character

  # Actions
  def index
    params[:per_page] ||= 25
    params[:search] = {"by_character" => ''}.merge(params[:search] || {})
  
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
    
    index!
  end

  # Return list of tags useable as suggestions in dossier search.
  def suggestions
    @query = params[:query]

    words = @query.split(/\s/)
    last_word = words.last
    previous_words = words[0..-2]

    suggestion_count = 10

    keywords = Keyword.unscoped.includes(:taggings).where("taggings.context = 'tags'")
    if words.size > 1
      dossiers = Dossier.includes(:taggings => :tag).where("taggings.context = 'tags'").limit(10).group('taggings.taggable_id').having("count(*) = #{words.size - 1}")

      word_conditions = previous_words.map{|word|
        "tags.name LIKE %s" % Dossier.connection.quote("%#{word}%")
      }
      dossiers = dossiers.where(word_conditions.join(" OR "))

      keywords = keywords.where("taggings.taggable_id" => dossiers, "taggings.taggable_type" => 'Dossier')
    end

    prefix_keywords = keywords.where("name LIKE ?", "#{last_word}%").order(:name).limit(10)
    infix_suggestion_count = suggestion_count - prefix_keywords.size
    infix_keywords = keywords.where("name NOT LIKE ? AND name LIKE ?", "%#{last_word}%", "#{last_word}%").order(:name).limit(infix_suggestion_count)

    suggestions = (prefix_keywords + infix_keywords).map{|keyword|
      {"keyword" => {"name", previous_words.join(" ") + " " + keyword.name}}
    }
    render :json => suggestions
  end
end
