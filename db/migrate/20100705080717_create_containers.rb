class CreateContainers < ActiveRecord::Migration
  def self.up
    create_table :containers do |t|
      t.references :dossier
      t.references :container_type
      t.references :location

      t.timestamps
    end
  end

  def self.down
    drop_table :containers
  end
end
