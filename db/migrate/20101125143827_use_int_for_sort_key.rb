class UseIntForSortKey < ActiveRecord::Migration
  def self.up
    change_column :dossiers, :sort_key, :integer
  end

  def self.down
    change_column :dossiers, :sort_key, :string
  end
end
