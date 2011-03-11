class RemoveSortKeyFromDossiers < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :sort_key
  end

  def self.down
    add_column :dossiers, :sort_key, :integer
  end
end
