class AddCodeIndexToLocation < ActiveRecord::Migration
  def self.up
    add_index :locations, :code, :length => 20
  end

  def self.down
    remove_index :locations, :code
  end
end
