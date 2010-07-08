class RemoveKeywordsFromDossier < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :keywords
  end

  def self.down
    add_column :dossiers, :keywords, :string
  end
end
