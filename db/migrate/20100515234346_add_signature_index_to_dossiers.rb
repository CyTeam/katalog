class AddSignatureIndexToDossiers < ActiveRecord::Migration
  def self.up
    add_index :dossiers, :signature
  end

  def self.down
    remove_index :dossiers, :signature
  end
end
