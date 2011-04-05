
require 'ostruct'

class DossiersController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :search, :show, :report]

  # Responders
  respond_to :html, :js, :json, :xls
  
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
    @dossier = Dossier.find(params[:id])
    authorize! :show, @dossier
    
    show! do |format|
      format.xls {
        send_data(@dossier.to_xls,
          :filename => "dossier_#{@dossier.signature}.xls",
          :type => 'application/vnd.ms-excel')
      }
    end
  end

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

  def report
    report_name = params[:report_name] || 'overview'
    @report = Report.find_by_name(report_name)
    
    # Preset parameters
    case report_name
      when 'index'
         @document_count = Dossier.document_count
         @report = Report.find_by_name('index')
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
    
    # Set pagination parameter
    params[:per_page] = @report[:per_page]
    
    @report[:title] ||= report_name
    
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
    @year = params[:dossier_numbers][:year] if params[:dossier_numbers]
    @year ||= Time.now.year - 1
    
    params[:search] ||= {}
    if params[:search][:text].present?
      @query = params[:search][:text]
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page])
    elsif params[:search][:signature].present?
      @query = params[:search][:signature]
      @dossiers = Dossier.by_signature(params[:search][:signature]).dossier.order('signature').paginate :page => params[:page], :per_page => params[:per_page]
    else
      # Show index
      @dossiers = Topic.where("char_length(signature) <= 2").paginate :page => params[:page], :per_page => 10000
      render 'batch_edit_last_year/index'
      return
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!
  end

  private
  def dossier_index
    params[:dossier] ||= {}
    params[:dossier][:level] ||= 2

    @dossiers = apply_scopes(Dossier, params[:dossier]).accessible_by(current_ability, :index)
    @document_count = Dossier.document_count

    index_excel
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
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?)
    else
      @query = params[:search][:signature]
      @dossiers = apply_scopes(Dossier, params[:search]).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]

      # Alphabetic pagination
      if Topic.alphabetic?(@query)
        @paginated_scope = Dossier.accessible_by(current_ability, :index).by_signature(@query)
      end
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    if (@dossiers.count == 1 and not request.format.json?)
      redirect_to dossier_path(@dossiers.first, :query => @query)
    else
      index_excel
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
      @dossiers = Dossier.by_text(params[:search][:text], :page => params[:page], :per_page => params[:per_page], :internal => current_user.present?)
    else
      @query = params[:search][:signature]
      params[:search].merge!(:per_page => @report[:per_page], :level => @report[:level])
      @dossiers = apply_scopes(Dossier, params[:search]).order('signature').accessible_by(current_ability, :index).paginate :page => params[:page], :per_page => params[:per_page]
    end

    # Drop nil results by stray full text search matches
    @dossiers.compact!

    index_excel
  end

  def index_excel
    index! do |format|
      format.xls {
        send_data(Dossier.to_xls(@dossiers),
          :filename => "dossiers_#{@dossiers.first.signature}.xls",
          :type => 'application/vnd.ms-excel')
      }
    end
  end
end
