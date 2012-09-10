class AddSortTitleToDossiers < ActiveRecord::Migration
  def change
    add_column :dossiers, :sort_title, :string

    add_index :dossiers, :sort_title
  end
end
