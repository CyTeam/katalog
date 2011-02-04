class ImportSphinxConfigurations < ActiveRecord::Migration
  def self.up
    SphinxAdmin.import
  end

  def self.down
    SphinxAdmin.all.each do |s|
      s.delete
    end
  end
end
