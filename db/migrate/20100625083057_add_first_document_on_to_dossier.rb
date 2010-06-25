class AddFirstDocumentOnToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :first_document_on, :date
  end

  def self.down
    remove_column :dossiers, :first_document_on
  end
end
