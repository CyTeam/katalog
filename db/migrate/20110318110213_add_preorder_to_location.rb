class AddPreorderToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :preorder, :boolean
  end

  def self.down
    remove_column :locations, :preorder
  end
end
