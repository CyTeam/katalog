class AddTitleColumnToContainerType < ActiveRecord::Migration
  def self.up
    add_column :container_types, :title, :string
  end

  def self.down
    remove_column :container_types, :title
  end
end
