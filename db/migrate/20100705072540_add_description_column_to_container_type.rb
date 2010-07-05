class AddDescriptionColumnToContainerType < ActiveRecord::Migration
  def self.up
    add_column :container_types, :description, :text
  end

  def self.down
    remove_column :container_types, :description
  end
end
