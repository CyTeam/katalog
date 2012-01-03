class AddNumberIdsToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :number_ids, :text
  end

  def self.down
    remove_column :versions, :number_ids
  end
end
