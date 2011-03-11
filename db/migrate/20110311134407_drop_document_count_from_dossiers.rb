class DropDocumentCountFromDossiers < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :document_count
  end

  def self.down
    add_column :dossiers, :document_count, :integer
  end
end
