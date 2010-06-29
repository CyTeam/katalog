class AddKeywordsToDossiers < ActiveRecord::Migration
  def self.up
    add_column :dossiers, :keywords, :text
  end

  def self.down
    remove_column :dossiers, :keywords
  end
end
