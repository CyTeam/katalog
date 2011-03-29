class SetInternalDefaultOfDossier < ActiveRecord::Migration
  def self.up
    Dossier.update_all('internal = false', 'internal is NULL')
    change_column_default :dossiers, :internal, false
  end

  def self.down
  end
end
