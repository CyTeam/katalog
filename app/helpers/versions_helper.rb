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
    version.item_type.constantize.find(version.item_id)
  end
end