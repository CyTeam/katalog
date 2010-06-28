class RemoveParentIdFromDossier < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :parent_id
  end

  def self.down
  end
end
