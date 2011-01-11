class AddDescriptionToDossiers < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :description, :text
  end

  def self.down
    remove_column :dossiers, :description
  end
end
