class AddIndexOnToAndFromDossierNumbers < ActiveRecord::Migration
  def self.up
    add_index :dossier_numbers, :to
    add_index :dossier_numbers, :from
  end

  def self.down
    remove_index :dossier_numbers, :to
    remove_index :dossier_numbers, :from
  end
end
