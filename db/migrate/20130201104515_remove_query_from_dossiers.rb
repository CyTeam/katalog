class RemoveQueryFromDossiers < ActiveRecord::Migration
  def up
    remove_column :dossiers, :query
  end

  def down
    add_column :dossiers, :query, :string
  end
end
