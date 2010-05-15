class CreateDossierNumbers < ActiveRecord::Migration
  def self.up
    create_table :dossier_numbers do |t|
      t.belongs_to :dossier
      t.date :to
      t.date :from
      t.integer :amount
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dossier_numbers
  end
end
