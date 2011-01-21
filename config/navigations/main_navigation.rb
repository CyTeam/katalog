# Configures your navigations
SimpleNavigation::Configuration.run do |navigation|  
  # Define the primary navigations
  navigation.items do |primary|
    # doku zug navigations
    primary.item :dossiers, "Dossiers", dossiers_path, :highlights_on => /\/dossiers/ do |dossier|
      dossier.item :index, "Auflistung", dossiers_path
      dossier.item :search, "Dossier suchen", search_dossiers_path
    end
    primary.item :key_words, t('controllers.index.keyword'), keywords_path

    if user_signed_in?
      primary.item :adminstration, "Verwaltung", locations_path do |administration|
        administration.item :locations, "Standorte", locations_path
        administration.item :dossier_types, "Dossier Arten", container_types_path
        administration.item :users, "Benutzer", users_path, :if => Proc.new { can?(:new, User) }
        administration.item :new_dossier, "Dossier anlegen", new_dossier_path, :hightlights_on => /\/dossiers\/new/, :if => Proc.new { can?(:new, Dossier) }
        administration.item :new_title, "Titel anlegen", new_topic_path, :if => Proc.new { can?(:new, Topic) }
      end
      primary.item :log_out, "Abmelden", destroy_user_session_path
    else
      primary.item :log_in, "Anmelden", new_user_session_path
    end
  end
end
