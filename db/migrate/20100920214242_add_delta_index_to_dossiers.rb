class AddDeltaIndexToDossiers < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :dossiers, :delta
  end
end
