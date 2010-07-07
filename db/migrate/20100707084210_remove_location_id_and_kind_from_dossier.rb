class RemoveLocationIdAndKindFromDossier < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :location_id
    remove_column :dossiers, :kind
  end

  def self.down
    add_column :dossiers, :kind, :string
    add_column :dossiers, :location_id, :integer
  end
end
