class UseIntegerForCollectYearCount < ActiveRecord::Migration
  def self.up
    change_column :reports, :collect_year_count, :integer
  end

  def self.down
  end
end
