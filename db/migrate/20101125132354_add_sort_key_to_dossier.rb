class AddSortKeyToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :sort_key, :string

    Dossier.update_all("sort_key = substring(signature, 4, 1)")
    Dossier.update_all("sort_key = '10'", "sort_key = '0'")
  end

  def self.down
    remove_column :dossiers, :sort_key
  end
end
