class AddSortKeyToDossiers < ActiveRecord::Migration
  def change
    add_column :dossiers, :sort_key, :string
  end
end
