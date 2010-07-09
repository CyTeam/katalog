class AddDocumentRelationToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :related_to, :string
  end

  def self.down
    remove_column :dossiers, :related_to
  end
end
