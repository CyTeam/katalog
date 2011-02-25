class AddLevelToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :level, :integer
  end

  def self.down
    remove_column :reports, :level
  end
end
