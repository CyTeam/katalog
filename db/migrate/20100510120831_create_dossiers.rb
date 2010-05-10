class CreateDossiers < ActiveRecord::Migration
  def self.up
    create_table :dossiers do |t|
      t.string :signature
      t.string :title
      t.string :type
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :dossiers
  end
end
