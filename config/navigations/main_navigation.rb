# Configures your navigations
SimpleNavigation::Configuration.run do |navigation|  
  # Define the primary navigations
  navigation.items do |primary|
    # doku zug navigations
    primary.item :dossiers, t('katalog.main_navigation.dossiers'), dossiers_path, :highlights_on => /\/dossiers/ do |dossier|
      dossier.item :index, t('katalog.main_navigation.dossier_index'), dossiers_path
      dossier.item :search, t('katalog.main_navigation.search'), search_dossiers_path
    end
    primary.item :key_words, t('controllers.index.keyword'), keywords_path

    if user_signed_in?
      primary.item :adminstration, t('katalog.main_navigation.administration'), locations_path do |administration|
        administration.item :locations, t('katalog.main_navigation.locations'), locations_path
        administration.item :dossier_types, t('katalog.main_navigation.container_types'), container_types_path
        administration.item :users, t('katalog.main_navigation.users'), users_path, :if => Proc.new { can?(:new, User) }
        administration.item :versions_nav, t('katalog.main_navigation.changes'), versions_path, :hightlights_on => /\/versions/, :if => Proc.new { current_user.role?'admin' }
        administration.item :edit_dossier_years, t('katalog.main_navigation.edit_year'), edit_report_dossiers_path, :if => Proc.new { can?(:update, Dossier) }
        administration.item :new_dossier, t('katalog.main_navigation.new_dossier'), new_dossier_path, :hightlights_on => /\/dossiers\/new/, :if => Proc.new { can?(:new, Dossier) }
        administration.item :new_title, t('katalog.main_navigation.new_title'), new_topic_path, :if => Proc.new { can?(:new, Topic) }
      end
      primary.item :log_out, t('katalog.main_navigation.logout'), destroy_user_session_path
    else
      primary.item :log_in, t('katalog.main_navigation.login'), new_user_session_path
    end
  end
end
