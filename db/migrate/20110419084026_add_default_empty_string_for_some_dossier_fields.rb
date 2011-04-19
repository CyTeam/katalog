class AddDefaultEmptyStringForSomeDossierFields < ActiveRecord::Migration
  def self.up
    Dossier.update_all("related_to = ''", "related_to IS NULL")
    change_column_default :dossiers, :related_to, ''

    Dossier.update_all("description = ''", "description IS NULL")
    change_column_default :dossiers, :description, ''
  end

  def self.down
  end
end
