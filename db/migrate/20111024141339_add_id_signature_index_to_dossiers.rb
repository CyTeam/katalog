class AddIdSignatureIndexToDossiers < ActiveRecord::Migration
  def self.up
    add_index :dossiers, :id
    add_index :dossiers, [:id, :signature], :unique => true
  end

  def self.down
    remove_index :dossiers, [:id, :signature]
    remove_index :dossiers, :id
  end
end
