class AddDocumentCountCacheToDossiers < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :document_count, :integer
    
    for dossier in Dossier.all
      dossier.update_document_count!
    end
  end

  def self.down
    remove_column :dossiers, :document_count
  end
end
