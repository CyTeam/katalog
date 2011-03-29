class AddInternalToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :internal, :boolean
  end

  def self.down
    remove_column :dossiers, :internal
  end
end
