class AddTypeToDossier < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :type, :string
  end

  def self.down
    remove_column :dossiers, :type
  end
end
