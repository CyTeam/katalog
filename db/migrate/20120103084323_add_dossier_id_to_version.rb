class AddDossierIdToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :dossier_id, :integer
  end

  def self.down
    remove_column :versions, :dossier_id
  end
end
