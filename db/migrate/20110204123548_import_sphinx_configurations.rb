class ImportSphinxConfigurations < ActiveRecord::Migration
  def self.up
    SphinxAdminWordForm.seed
    SphinxAdminException.seed
  end

  def self.down
    SphinxAdmin.delete_all
  end
end
