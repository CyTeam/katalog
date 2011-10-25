class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.string :first_name
      t.string :last_name
      t.integer :dossier_id
      t.string :dossier_years
      t.string :email
      t.datetime :pickup

      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
