class UpdateSignatureIndexInDossiers < ActiveRecord::Migration
  def self.up
    remove_index :dossiers, :signature
    add_index :dossiers, :signature, :length => 20
  end

  def self.down
    remove_index :dossiers, :signature
    add_index :dossiers, :signature
  end
end
