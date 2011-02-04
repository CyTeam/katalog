class ImportSphinxConfigurations < ActiveRecord::Migration
  def self.up
    SphinxAdmin.initial_import
  end

  def self.down
  end
end
