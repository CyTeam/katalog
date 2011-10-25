require 'ostruct'

class DossiersController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show, :report]

  # Responders
  respond_to :html, :js, :json, :xls, :pdf
  
  # Search
  has_scope :by_text, :as => :text
  has_scope :by_signature, :as => :signature
  has_scope :by_title, :as => :title
  has_scope :by_location, :as => :location
  has_scope :by_kind, :as => :kind
  has_scope :by_character
  has_scope :by_level, :as => :level
  
  # Tags
  has_scope :tagged_with, :as => :tag
  
  # Ordering
  has_scope :order_by, :default => 'signature'

  def show
    if user_signed_in?
      @dossier = Dossier.find(params[:id], :include => {:containers => [:location, :container_type]})
    else
      @dossier = Dossier.find(params[:id])
    end
    
    authorize! :show, @dossier
    
    show! do |format|
      format.xls {
        send_data(@dossier.to_xls,
          :filename => "#{@dossier}.xls",
          :type => 'application/vnd.ms-excel')
      }
    end
  end

  # GET /dossiers
  def index
    params[:dossier] ||= {}
    params[:dossier][:level] ||= 2

    @dossiers = apply_scopes(Dossier, params[:dossier]).accessible_by(current_ability, :index)
    @document_count = Dossier.document_count

    index_excel
  end

  # GET /dossiers/search
  def search
    dossier_search
  end

  def new
    @dossier = Dossier.new(params[:dossier])
    @dossier.build_default_numbers
    
    new!
  end

  def edit
    @dossier = Dossier.find(params[:id])
    @dossier.build_default_numbers if @dossier.numbers.empty?
    @dossier.prepare_numbers
    
    edit!
  end

  def report
    report_name = params[:report_name] || 'overview'
    @report = Report.find_by_name(report_name)
    
    # Preset parameters
    case report_name
      when 'index'
         @document_count = Dossier.document_count
    end

    # Sanitize and use columns parameter if present
    if params[:columns]
      @report[:columns] = params[:columns].split(',').select{|column| Dossier.columns.include?(column)}
    end

    # Set pagination parameter
    params[:per_page] = @report[:per_page]
    @report[:title] ||= report_name
    @is_a_report = true
    
    dossier_report
  end

  def edit_report
    # Stay on this action after search
    @search_path = edit_report_dossiers_path

    # Pagination
    params[:per_page] ||= 50
    if params[:per_page] == 'all'
      # Simple hack to simulate all
      params[:per_page] = 1000000
    end

    # Collection setup
    @years = DossierNumber.edit_years(params[:dossier_numbers]) if params[:dossier_numbers]
    @years ||= [Time.now.year - 1] if params[:search]
    
    params[:search] ||= {}
    if params[:search][:text].present?
      @query = params[:search][:text]
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page])
    elsif params[:search][:signature].present?
      @query = params[:search][:signature]
      @dossiers = Dossier.by_signature(params[:search][:signature]).dossier.order('signature').paginate :page => params[:page], :per_page => params[:per_page]
    else
      # Show index
      @dossiers = Topic.by_level(2)
      render 'batch_edit_last_year/index'
      return
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = self.class.helpers.link_to(t('katalog.created', :signature => @dossier.signature, :title => @dossier.title), dossier_path(@dossier))
        redirect_to new_resource_url
      end
    end
  end
  
  private
  def dossier_search
    params[:per_page] ||= 25

    params[:search] ||= {}
    params[:search][:text] ||= params[:search][:query]
    params[:search][:text] ||= params[:query]

    if params[:per_page] == 'all'
      # Simple hack to simulate all
      params[:per_page] = 1000000
    end
    if params[:search][:text].present?
      @query = params[:search][:text]
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?, :include => [:location, :containers])
    else
      @query = params[:search][:signature]
      @dossiers = apply_scopes(Dossier, params[:search]).includes(:containers => :location).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]

      # Alphabetic pagination
      if Topic.alphabetic?(@query)
        @paginated_scope = Dossier.accessible_by(current_ability, :index).by_signature(@query)
      end
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    # Handle zero and single matches for direct user requests
    if not request.format.json?
      # Directly show single match
      if @dossiers.count == 1
        redirect_to dossier_path(@dossiers.first, :query => @query)
      # Give spellchecking suggestions
      elsif @dossiers.count == 0
        spell_checker = Aspell.new1({"dict-dir" => Rails.root.join('data', 'aspell').to_s, "lang"=>"kt"})
        spell_checker.set_option("ignore-case", "true")
        spell_checker.suggestion_mode = Aspell::NORMAL

        @spelling_suggestion = @query.gsub(/[\w\']+/) do |word|
          if spell_checker.check(word)
            word
          else
            # word is wrong
            suggestion = spell_checker.suggest(word).first
            #if suggestion.blank?
              # Try harder
              #spell_checker.suggestion_mode = Aspell::BADSPELLER
              #suggestion = spell_checker.suggest(word).first
            #end
            if suggestion.blank?
              # Return original word
              suggestion = word
            end

            suggestion
          end
        end
      else
        index_excel
      end
    else
      render :json => @dossiers
    end
  end

  def dossier_report
    params[:per_page] ||= 'all'

    params[:search] ||= {}
    params[:search][:text] ||= params[:search][:query]
    params[:search][:text] ||= params[:query]

    if params[:per_page] == 'all'
      # Simple hack to simulate all
      params[:per_page] = 1000000
    end
    if params[:search][:text].present?
      @query = params[:search][:text]
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?, :include => [:location, :containers, :keywords])
    else
      @query = params[:search][:signature]
      params[:search].merge!(:per_page => @report[:per_page], :level => @report[:level])
      @dossiers = apply_scopes(Dossier, params[:search]).includes(:containers => :location).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    index_excel
  end

  def index_excel
    index! do |format|
      format.xls {
        if params[:search] and params[:search][:signature]
          filename = @dossiers.first.to_s
        else
          filename = t('katalog.search_for', :query => @query)
        end

        excel = params[:excel_format] == 'containers' ? Dossier.to_container_xls(@dossiers) : Dossier.to_xls(@dossiers)
        
        send_data(excel,
          :filename => "#{filename}.xls",
          :type => 'application/vnd.ms-excel')
      }
    end
  end
end
