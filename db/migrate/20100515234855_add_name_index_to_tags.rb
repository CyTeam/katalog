class AddNameIndexToTags < ActiveRecord::Migration
  def self.up
    add_index :tags, :name
  end

  def self.down
    remove_index :tags, :name
  end
end
