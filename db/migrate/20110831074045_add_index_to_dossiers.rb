class AddIndexToDossiers < ActiveRecord::Migration
  def self.up
    add_index :dossiers, :internal
  end

  def self.down
  end
end
