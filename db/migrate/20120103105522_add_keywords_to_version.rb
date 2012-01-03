class AddKeywordsToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :keywords, :text
  end

  def self.down
    remove_column :versions, :keywords
  end
end
