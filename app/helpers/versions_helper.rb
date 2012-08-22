# encoding: UTF-8

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
    return version.reify.to_s if version.event.eql?('destroy')

    version.active_item.to_s
  end

  def user_email(version)
    User.find(version.whodunnit).email if version.whodunnit
  end

  def action(version)
    t(version.event, :scope => "katalog.versions.actions")
  end

  def active_main_item(version)
    item = version.active_item
    
    case item.class.name
    when 'DossierNumber', 'Container', 'Keyword'
      return item.dossier
    else
      return item
    end
  end
  
  def dossier?(version)
    case version.item_type
    when 'DossierNumber', 'Container', 'Keyword', 'Dossier'
      true
    else
      false
    end
  end
end
