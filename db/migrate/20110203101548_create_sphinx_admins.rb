class CreateSphinxAdmins < ActiveRecord::Migration
  def self.up
    create_table :sphinx_admins do |t|
      t.string :type
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :sphinx_admins
  end
end
