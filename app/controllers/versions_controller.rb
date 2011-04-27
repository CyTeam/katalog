class VersionsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def attributes
    ['item_type', 'object', 'changed_from', 'changed_at', 'action']
  end
  
  def show
    @version = Version.find(params[:id])
    
    case @version.event
      when "create"
        if @version.next
          @current_item = @version.next.reify
        else
          @current_item = @version.item
        end
        @previous_item = nil
        @versions = @current_item.versions
      when "update"
        if @version.next
          @current_item = @version.next.reify
        else
          # Use active item as it should exist
          @current_item = @version.item
        end
        @previous_item = @current_item.previous_version
        @versions = @current_item.versions
      when "destroy"
        @current_item = nil
        @previous_item = @version.reify
        @versions = @previous_item.versions
    end
    
    @versions = @versions.paginate(:page => params[:page])
    show!
  end
  
  def index
    if params[:dossier_id]
      dossiers = Dossier.find(params[:dossier_id])
      @versions = dossiers.versions.order('created_at DESC').paginate(:page => params[:page])
      dossiers.numbers.each do |n|
        n.versions.each do |v|
          @versions << v
        end
      end
    else
      @versions = Version.order('created_at DESC').paginate(:page => params[:page])
    end

    index!
  end

  def revert
    @version = Version.find(params[:id])
    
    @version.revert
    
    redirect_to versions_path

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
