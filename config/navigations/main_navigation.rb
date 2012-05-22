# Configures your navigations
SimpleNavigation::Configuration.run do |navigation|  
  # Define the primary navigations
  navigation.items do |primary|
    # doku zug navigations
    primary.item :root, t('katalog.main_navigation.root'), root_path, :unless => lambda { user_signed_in? }
    primary.item :nav_dossiers, t('katalog.main_navigation.dossiers'), dossiers_path, :highlights_on => /\/dossiers($|\/search)/ do |dossier|
      dossier.item :index, t('katalog.main_navigation.dossier_index'), dossiers_path
      dossier.item :search, t('katalog.main_navigation.search'), search_dossiers_path, :highlights_on => /\/dossiers(\/\d*$|\/search|$)/
    end
    primary.item :key_words, t('controllers.index.keyword'), keywords_path, :if => lambda { user_signed_in? }

    if current_user and (current_user.role?(:editor) or current_user.role?(:admin))
      primary.item :edit, t('katalog.main_navigation.edit'), versions_path do |edit|
        edit.item :new_dossier, t('katalog.main_navigation.new_dossier'), new_dossier_path
        edit.item :new_title, t('katalog.main_navigation.new_title'), new_topic_path
        edit.item :new_query_title, t('katalog.main_navigation.new_query_topic'), new_query_topic_path
        edit.item :query_title_list, t('katalog.main_navigation.query_topic_list'), query_topics_path
        edit.item :edit_dossier_years, t('katalog.main_navigation.edit_year'), edit_report_dossiers_path, :highlights_on => /\/dossiers\/edit_report/
        edit.item :search_replace, t('katalog.main_navigation.search_replace'), search_replaces_path
        edit.item :versions_nav, t('katalog.main_navigation.changes'), versions_path, :highlights_on => /\/versions($|\/[0-9]*($|\/.*))/
      end
      primary.item :visitor_logs, t('katalog.main_navigation.visitor_logs'), visitor_logs_path, :highlights_on => /\/visitor_logs/
    end
    
    if current_user and current_user.role?(:admin)
      primary.item :adminstration, t('katalog.main_navigation.administration'), users_path do |administration|
        administration.item :users, t('katalog.main_navigation.users'), users_path, :highlights_on => /\/users($|\/new|\/\d*)/
        administration.item :locations, t('katalog.main_navigation.locations'), locations_path, :highlights_on => /\/locations($|\/new|\/\d*)/
        administration.item :container_types, t('katalog.main_navigation.container_types'), container_types_path, :highlights_on => /\/container_types/
        administration.item :reports, t('katalog.main_navigation.reports'), reports_path, :highlights_on => /\/reports/
        administration.item :dangling_relations, t('dossiers.dangling_relations.title'), dangling_relations_dossiers_path
        administration.item :sphinx, t('katalog.main_navigation.search_admin'), exceptions_sphinx_admins_path do |sphinx|
          sphinx.item :exceptions, t('katalog.main_navigation.search_exceptions'), exceptions_sphinx_admins_path
          sphinx.item :word_forms, t('katalog.main_navigation.search_word_forms'), word_forms_sphinx_admins_path
        end
      end
    end
    
    if current_user
      primary.item :log_out, t('katalog.main_navigation.logout'), destroy_user_session_path
    else
      primary.item :log_in, t('katalog.main_navigation.login'), new_user_session_path
    end
  end
end
