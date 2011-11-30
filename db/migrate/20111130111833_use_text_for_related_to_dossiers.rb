class UseTextForRelatedToDossiers < ActiveRecord::Migration
  def self.up
    change_column :dossiers, :related_to, :text
  end

  def self.down
    change_column :dossiers, :related_to, :string, :default => ''
  end
end
