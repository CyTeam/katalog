class CollectYearCountToString < ActiveRecord::Migration
  def self.up
    change_column :reports, :collect_year_count, :string
  end

  def self.down
    change_column :reports, :collect_year_count, :integer
  end
end
