class DropNewSignatureSupport < ActiveRecord::Migration
  def self.up
    remove_column :dossiers, :new_signature
  end

  def self.down
    add_column :dossiers, :new_signature, :string
  end
end
