class AddParentIdToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :parent_id, :integer
  end

  def self.down
    remove_column :dossiers, :parent_id
  end
end
