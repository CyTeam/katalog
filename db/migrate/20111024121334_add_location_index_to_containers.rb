class AddLocationIndexToContainers < ActiveRecord::Migration
  def self.up
    add_index :containers, :location_id
  end

  def self.down
    remove_index :containers, :location_id
  end
end
