# encoding: UTF-8

require 'ostruct'
require 'raspell'

class DossiersController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show, :report, :preview, :welcome]

  # Responders
  respond_to :html, :js, :json, :xls, :pdf

  # Search
  has_scope :by_title, :as => :title
  has_scope :by_character
  has_scope :by_level, :as => :level

  # Tags
  has_scope :tagged_with, :as => :tag

  # CRUD Actions
  # ============
  def show
    # Set query for highlighting and search form prefill
    @query = params[:search][:text]

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

  def new
    @dossier = Dossier.new(params[:dossier])
    @dossier.build_default_numbers

    @dossier.containers.build(:container_type_code => 'DH')

    new!
  end

  def edit
    @dossier = Dossier.find(params[:id])
    @dossier.build_default_numbers if @dossier.numbers.empty?
    @dossier.prepare_numbers

    edit!
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = self.class.helpers.link_to(t('katalog.created', :signature => @dossier.signature, :title => @dossier.title), dossier_path(@dossier))
        redirect_to new_resource_url
      end
    end
  end


  # Index Actions
  # =============
  def welcome
    @groups = Dossier.group

    redirect_to :action => 'index' if user_signed_in?
  end

  def index
    params[:dossier] ||= {}
    params[:dossier][:level] ||= 2

    @dossiers = apply_scopes(Dossier, params[:dossier]).accessible_by(current_ability, :index)
    @document_count = Dossier.document_count

    index_excel
  end

  def search
    dossier_search
  end


  # Report Actions
  # ==============
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
    params[:per_page] = @report[:per_page] || 'all'
    @report[:title] ||= report_name
    @is_a_report = true

    dossier_report
  end

  def edit_report
    setup_per_page
    setup_query

    # Show index if called with no query
    if @query.blank?
      @dossiers = Topic.by_level(2)
      render 'batch_edit_last_year/index' and return
    end

    # Stay on this action after search
    @search_path = edit_report_dossiers_path

    # Collection setup
    @years = DossierNumber.edit_years(params[:dossier_numbers]) if params[:dossier_numbers]
    @years ||= [Time.now.year - 1]

    if !@signature_search
      @dossiers = Dossier.by_text(@query, :page => params[:page], :per_page => params[:per_page])
    else
      order_attribute = (@query && Topic.alphabetic?(@query)) ? 'signature, title' : 'signature' # Sort with title when query is within an alphabetic topic.
      @dossiers = Dossier.by_signature(@query).dossier.order(order_attribute).paginate :page => params[:page], :per_page => params[:per_page]
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!
  end

  def preview
    show!
  end

  # Dangling relates_to list
  def dangling_relations
    @dossiers = Dossier.with_dangling_relations
  end

  def multi_relations
    @dossiers = Dossier.with_multi_relations
  end

  private
  def setup_per_page
    params[:per_page] ||= 25

    if params[:per_page] == 'all'
      # Simple hack to simulate all
      params[:per_page] = 1000000
    end
  end

  def setup_query
    params[:search] ||= {}
    @query = params[:search][:text].try(:strip) || ''
    @signature_search = /^[0-9.]{1,8}$/.match(@query)
  end

  def dossier_search
    setup_per_page
    setup_query

    if !@signature_search
      @dossiers = Dossier.by_text(@query, :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?, :include => [:location, :containers])
    else
      @dossiers = apply_scopes(Dossier, params[:search]).by_signature(@query).includes(:containers => :location).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]

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
        redirect_to dossier_path(@dossiers.first, :search => {:text => @query})
      # Give spellchecking suggestions
      elsif @dossiers.count == 0
        spell_checker = Aspell.new1({"dict-dir" => Rails.root.join('db', 'aspell').to_s, "lang"=>"kt", "encoding"=>"UTF-8"})
        spell_checker.set_option("ignore-case", "true")
        spell_checker.suggestion_mode = Aspell::NORMAL

        german_spell_checker = Aspell.new1({'lang' => 'de_CH', "encoding"=>"UTF-8"})
        german_spell_checker.set_option("ignore-case", "true")
        german_spell_checker.suggestion_mode = Aspell::NORMAL

        @spelling_suggestion = {}
        @query.gsub(/[\w\']+/) do |word|
          if word =~ /[0-9]/
            word
          elsif spell_checker.check(word)
            word
          else
            # word is wrong
            suggestion = spell_checker.suggest(word).first
            #if suggestion.blank?
              # Try harder
              #spell_checker.suggestion_mode = Aspell::BADSPELLER
              #suggestion = spell_checker.suggest(word).first
            #end

            if suggestion
              suggestion = german_spell_checker.suggest(suggestion).first
            else
              suggestion = german_spell_checker.suggest(word).first
            end

            @spelling_suggestion[word] = suggestion if (suggestion.present? && !Dossier.by_text(suggestion).empty? && !(suggestion =~ %r[#{word}] or suggestion == nil))
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
    setup_per_page
    setup_query

    if !@signature_search
      @dossiers = Dossier.by_text(@query, :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?, :include => [:location, :containers, :keywords])
    else
      params[:search].merge!(:per_page => @report[:per_page], :level => @report[:level])
      @dossiers = apply_scopes(Dossier, params[:search]).by_signature(@query).includes(:containers => :location).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    index_excel
  end

  def index_excel
    index! do |format|
      format.xls {
        if @signature_search
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
