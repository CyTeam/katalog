class AddSomeDocumentColumnsToContainers < ActiveRecord::Migration
  def self.up
    add_column :containers, :first_document_on, :date
    add_column :containers, :title, :string
  end

  def self.down
    remove_column :containers, :title
    remove_column :containers, :first_document_on
  end
end
