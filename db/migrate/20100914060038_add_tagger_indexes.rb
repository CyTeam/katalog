class AddTaggerIndexes < ActiveRecord::Migration
  def self.up
    add_index :taggings, [:tagger_id, :tagger_type]
  end

  def self.down
    remove_index :taggings, [:tagger_id, :tagger_type]
  end
end
