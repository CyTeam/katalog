class UpdateNameIndexInTags < ActiveRecord::Migration
  def self.up
    remove_index :tags, :name
    add_index :tags, :name, :length => 10
  end

  def self.down
    remove_index :tags, :name
    add_index :tags, :name
  end
end
