class AddIndicesToDossiers < ActiveRecord::Migration
  def self.up
    # Associations
    add_index :dossiers, :parent_id
    add_index :dossiers, :location_id

    # Polymorphic
    add_index :dossiers, :type
    
    # Order/Scope
    add_index :dossiers, :kind
  end

  def self.down
    remove_index :dossiers, :parent_id
    remove_index :dossiers, :location_id
    remove_index :dossiers, :type
    remove_index :dossiers, :kind
  end
end
