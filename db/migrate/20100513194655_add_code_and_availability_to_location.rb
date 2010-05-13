class AddCodeAndAvailabilityToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :code, :string
    add_column :locations, :availability, :string
  end

  def self.down
    remove_column :locations, :code
    remove_column :locations, :availability
  end
end
