class UseFirstDocumentOnInDossiers < ActiveRecord::Migration
  def self.up
    execute "UPDATE dossiers SET first_document_on = (SELECT min(first_document_on) FROM containers WHERE containers.dossier_id = dossiers.id)"
    
    remove_column :containers, :first_document_on
  end

  def self.down
    add_column :containers, :first_document_on, :datetime
  end
end
