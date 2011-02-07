class ImportSphinxConfigurations < ActiveRecord::Migration
  def self.up
    SphinxAdminWordForm.rewrite
    SphinxAdminException.rewrite
  end

  def self.down
    SphinxAdmin.delete_all
  end
end
