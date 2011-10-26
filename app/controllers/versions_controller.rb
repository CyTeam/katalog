class VersionsController < AuthorizedController

  include VersionsHelper
  # Authentication
  before_filter :authenticate_user!

  def attributes
    ['item_type', 'object', 'changed_from', 'changed_at', 'action']
  end
  
  def show
    @version = Version.find(params[:id])
    
    @current_item = @version.current_item
    @previous_item = @version.previous_item

    @versions = @version.versions.reorder('created_at DESC').paginate(:page => params[:page])

    show!
  end
  
  def index
    if params[:dossier_id]
      dossier = Dossier.find(params[:dossier_id])
      @versions = Version.where("(item_type = 'Dossier' AND item_id = ?) OR (item_type = 'DossierNumber' AND item_id IN (?))", dossier.id, dossier.number_ids)
    else
      @versions = Version
    end

    @versions = @versions.reorder('created_at DESC').paginate(:page => params[:page])
    index!
  end

  def revert
    @version = Version.find(params[:id])
    
    @version.revert
    
    if dossier?@version
      redirect_to dossier_versions_path(active_main_item(@version))
    else
      redirect_to :back
    end

    return
    
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
      object.id_attributes.each do |name, id|
        sub_version = Version.find_by_item_id(id)
        sub_object = sub_version.reify
        sub_original = ('destroy'.eql?sub_version.event ? nil : sub_version.item_type.constantize.find(sub_version.item_id))
        if sub_original
          sub_original = sub_object
          sub_original.save
        else
          sub_object.save
        end
      end
    else
      version.item_type.constantize.find(version.item_id).destroy
    end
    
    redirect_to :action => 'index'
  end
end
