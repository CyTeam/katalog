class AddPublicOptionToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :public, :boolean
  end

  def self.down
    remove_column :reports, :public
  end
end
