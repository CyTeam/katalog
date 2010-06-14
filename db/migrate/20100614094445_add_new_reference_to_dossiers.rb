class AddNewReferenceToDossiers < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :new_signature, :string
  end

  def self.down
    remove_column :dossiers, :new_signature
  end
end
