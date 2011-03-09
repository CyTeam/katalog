class VersionsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def index
    if params[:dossier_id]
      dossiers = Dossier.find(params[:dossier_id])
      @versions = dossiers.versions.paginate(:page => params[:page])
      dossiers.numbers.each do |n|
        n.versions.each do |v|
          @versions << v
        end
      end
    end

    index!
  end

  def restore
    object = Version.find(params[:id]).reify
    original = object.class.find(object.id)
    original = object
    original.save
    
    redirect_to :action => 'index'
  end

  private
  def paginated_dossiers

  end
end
