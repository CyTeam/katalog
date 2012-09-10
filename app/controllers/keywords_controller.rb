# encoding: UTF-8

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

    @query = params[:search][:text]

    @keywords = apply_scopes(Keyword, params[:search]).where("name LIKE ?", "%#{@query}%").order(:name).paginate(:per_page => params[:per_page], :page => params[:page])
    @paginated_scope = Keyword.where("name LIKE ?", "%#{@query}%")
    
    index!
  end

  # Return list of tags useable as suggestions in dossier search.
  def suggestions
    @query = params[:query]

    words = @query.split(/\s/)
    last_word = words.last.strip
    previous_words = words[0..-2].map{|word| word.strip}

    suggestion_count = 10

    keywords = Keyword.unscoped.joins(:taggings).where("taggings.context = 'tags'").group('tags.id').order('COUNT(taggings.taggable_id) DESC')
    if words.size > 1
      dossiers = Dossier.by_text(previous_words.join(" "))

      keywords = keywords.where("taggings.taggable_id" => dossiers, "taggings.taggable_type" => 'Dossier')
    end

    prefix_keywords = keywords.where("name LIKE ?", "#{last_word}%").limit(10)
    infix_suggestion_count = suggestion_count - prefix_keywords.to_a.size
    infix_keywords = keywords.where("name NOT LIKE ? AND name LIKE ?", "#{last_word}%", "%#{last_word}%").limit(infix_suggestion_count)

    suggestions = (prefix_keywords + infix_keywords).map{|keyword|
      keywords = (previous_words + [keyword.name]).join(" ")
      query = Dossier.build_query(keywords)

      # Only count internal dossiers if user is logged in
      attributes = {}
      attributes[:internal] = false unless current_user.present?

      params = {:match_mode => :extended, :rank_mode => :match_any, :with => attributes}
      count = Dossier.search_count query, params
      {
        "keyword" => {
          "name"  => keywords,
          "count" => count
        }
      }
    }

    # Drop suggestions with count = 0
    suggestions.reject! {|suggestion| suggestion["keyword"]["count"] == 0}

    render :json => suggestions
  end
end
