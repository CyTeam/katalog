class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :name
      t.string :title
      t.string :orientation
      t.string :collect_year_count
      t.string :columns
      t.string :per_page

      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
