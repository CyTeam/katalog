class AddIndexOnSortKey < ActiveRecord::Migration
  def change
    add_index :dossiers, :sort_key
  end
end
