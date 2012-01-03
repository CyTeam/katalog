class AddContainerIdsToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :container_ids, :text
  end

  def self.down
    remove_column :versions, :container_ids
  end
end
