require 'ostruct'

class DossiersController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show]
  
  # Responders
  respond_to :html, :js, :json
  
  # Search
  has_scope :by_text, :as => :text
  has_scope :by_signature, :as => :signature
  has_scope :by_title, :as => :title
  has_scope :by_location, :as => :location
  has_scope :by_kind, :as => :kind
  has_scope :by_character
  
  # Tags
  has_scope :tagged_with, :as => :tag
  
  # Ordering
  has_scope :order_by, :default => 'signature'
  
  # GET /dossiers
  def index
    dossier_index
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
    @dossier.prepare_numbers
    
    edit!
  end

  def overview
    @report = {}
    @report[:collect_year_count] = (params[:collect_year_count] || 5).to_i

    index
  end

  def report
    report_name = params[:report_name] || 'overview'
    @report = {}
    
    # Preset parameters
    case report_name
      when 'overview'
        @report[:orientation] = 'landscape'
        @report[:columns] = [:signature, :title, :first_document_year, :container_type, :location, :keyword_text]

      when 'year'
        @report[:orientation] = 'landscape'
        @report[:collect_year_count] = (params[:collect_year_count] || 1).to_i
        @report[:columns] = [:signature, :title, :first_document_year]
    end

    # Sanitize and use columns parameter if present
    if params[:columns]
      @report[:columns] = params[:columns].split(',').select{|column| Dossier.columns.include?(column)}
    end

    # Pass landscape options to PDFKit
    if @report[:orientation] == 'landscape'
      @pdfkit_options = {
        'orientation'  => 'Landscape',
        'margin-left'  => '0.2cm',
        'margin-right' => '0.2cm'
      }
    end
    
    search
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
    @year = params[:year]
    
    if params[:search][:text].present?
      @query = params[:search][:text]
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page])
    elsif params[:search][:signature].present?
      @query = params[:search][:signature]
      @dossiers = Dossier.by_signature(params[:search][:signature]).dossier.order('signature').paginate :page => params[:page], :per_page => params[:per_page]
    else
      @dossiers = Topic.where("char_length(signature) <= 2").paginate :page => params[:page], :per_page => 10000
      render 'index'
      return
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!
  end

  private
  def dossier_index
    params[:dossier] ||= {}

    @dossiers = apply_scopes(Topic, params[:dossier]).where("char_length(signature) <= 2")
    @document_count = Dossier.document_count

    index!
  end

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
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page])
    else
      @query = params[:search][:signature]
      @dossiers = apply_scopes(Dossier, params[:search]).order('signature').paginate :page => params[:page], :per_page => params[:per_page]

      # Alphabetic pagination
      alphabetic_topics = ['15', '15.0', '15.0.100', '56', '56.0.130', '56.0.500', '81', '81.5', '81.5.100']
      if alphabetic_topics.include?(@query)
        @paginated_scope = Dossier.by_signature(@query)
      end
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    if (@dossiers.count == 1 and not request.format.json?)
      redirect_to dossier_path(@dossiers.first, :query => @query)
    else
      index!
    end
  end
end
