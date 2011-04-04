class CreateVisitorLogs < ActiveRecord::Migration
  def self.up
    create_table :visitor_logs do |t|
      t.string :title
      t.text :content
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :visitor_logs
  end
end
