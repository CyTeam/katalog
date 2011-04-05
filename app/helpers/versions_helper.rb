module VersionsHelper
  def change_type(previous, current)
    if previous == current
      return "unchanged"
    elsif previous.nil?
      return "added"
    elsif current.nil?
      return "removed"
    else
      return "changed"
    end
  end
  
  def version_title(version = nil)
    version ||= @version
    if version.event == "destroy"
      item = version.reify
    else
      item = version.item
    end
    
    item.to_s
  end

  def user_email(version)
    User.find(version.whodunnit).email if version.whodunnit
  end

  def action(version)
    t(version.event, :scope => "katalog.versions.actions")
  end

  def current_object_path(version)
    case version.item_type
      when 'DossierNumber'
      model_name = Dossier.to_s.pluralize.underscore
      model_id = DossierNumber.find(version.item_id).dossier_id
      else
      model_name = version.item_type.pluralize.underscore
      model_id = version.item_id
    end
    "/#{model_name}/#{model_id}"
  end
end
