module VersionsHelper
  def model_name(version)
    I18n.t("activerecord.models.#{version.item_type.underscore}")
  end

  def user_email(version)
    User.find(version.whodunnit).email if version.whodunnit
  end

  def difference_to_current(version)
    link_to 'Differenz anzeigen zum aktuellen Eintrag', version, :class => 'icon-show-text'
  end

  def original(version)
    version.item_type.constantize.exists?(version.item_id) ? version.item_type.constantize.find(version.item_id) : nil
  end

  def action(version)
    I18n.t("katalog.versions.actions.#{version.event}")
  end

  def differences(version)
    object_after = next_object(version) ? next_object(version) : original(version)
    changes = Version.differences(version, object_after) if version.reify
    # Ignore timestamps and Model specific boring attributes
    ignore_attributes = ["created_at", "updated_at"] + version.item_type.constantize.ignore
    return [] unless changes

    changes.select{|change| !ignore_attributes.include?(change[:attribute])}
  end

  def next_object(version)
    version.next ? version.next.reify : nil
  end
end
