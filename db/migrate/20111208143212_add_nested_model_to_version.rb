class AddNestedModelToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :nested_model, :boolean, :default => false
  end

  def self.down
    remove_column :versions, :nested_model
  end
end
