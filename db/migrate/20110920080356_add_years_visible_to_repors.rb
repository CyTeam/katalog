class AddYearsVisibleToRepors < ActiveRecord::Migration
  def self.up
    add_column :reports, :years_visible, :boolean, :default => true
  end

  def self.down
    remove_column :reports, :years_visible 
  end
end
