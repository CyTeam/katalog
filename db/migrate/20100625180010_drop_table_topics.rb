class DropTableTopics < ActiveRecord::Migration
  def self.up
    drop_table :topics
  end

  def self.down
  end
end
