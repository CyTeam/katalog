class UnifyTopicClasses < ActiveRecord::Migration
  def self.up
    execute "UPDATE dossiers SET type = 'Topic' WHERE type LIKE 'Topic%'"
  end

  def self.down
  end
end
