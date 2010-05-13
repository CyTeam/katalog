class ChangeDossierLocationToAssociation < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :location_id, :integer
    remove_column :dossiers, :location
  end

  def self.down
    add_column :dossiers, :location, :string
    remove_column :dossiers, :location_id
  end
end
