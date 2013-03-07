class ChangePickupToDate < ActiveRecord::Migration
  def up
    change_column :reservations, :pickup, :date
  end

  def down
    change_column :reservations, :pickup, :datetime
  end
end
