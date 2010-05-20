class AddIndexToDossierNumbers < ActiveRecord::Migration
  def self.up
    add_index :dossier_numbers, :dossier_id
  end

  def self.down
    remove_index :dossier_numbers, :dossier_id
  end
end
