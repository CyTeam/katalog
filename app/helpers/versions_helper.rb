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
  
  def title(version)
    old_object = version.reify

    old_object.to_s.empty? ? version.item.to_s : old_object.to_s
  end

  def user_email(version)
    User.find(version.whodunnit).email if version.whodunnit
  end

  def action(version)
    t(version.event, :scope => "katalog.versions.actions")
  end
end
