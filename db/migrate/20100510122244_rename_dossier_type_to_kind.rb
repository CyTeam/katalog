class RenameDossierTypeToKind < ActiveRecord::Migration
  def self.up
    rename_column :dossiers, :type, :kind
  end

  def self.down
    rename_column :dossiers, :kind, :type
  end
end
