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
    version = Version.find(params[:id])
    object = version.reify
    if object
      original = 'destroy'.eql?version.event ? nil : object.class.find(object.id)
      if original
        original = object
        original.save
      else
        object.save
      end
    else
      version.item_type.constantize.find(version.item_id).destroy
    end
    
    redirect_to :action => 'index'
  end

  private
  def paginated_dossiers

  end
end
