class AddQueryToQueryTopic < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :query, :string
  end

  def self.down
    remove_column :dossiers, :query
  end
end
