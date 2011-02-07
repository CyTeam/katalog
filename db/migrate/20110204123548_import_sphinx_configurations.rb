class ImportSphinxConfigurations < ActiveRecord::Migration
  def self.up
    SphinxAdmin.import
  end

  def self.down
    SphinxAdmin.delete_all
  end
end
