class UseDefaultsForReport < ActiveRecord::Migration
  def self.up
    change_column_default :reports, :orientation, 'landscape'
  end

  def self.down
  end
end
