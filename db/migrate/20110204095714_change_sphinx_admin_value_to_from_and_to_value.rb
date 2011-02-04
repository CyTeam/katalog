class ChangeSphinxAdminValueToFromAndToValue < ActiveRecord::Migration
  def self.up
    remove_column :sphinx_admins, :value
    add_column    :sphinx_admins, :from, :string
    add_column    :sphinx_admins, :to,   :string
  end

  def self.down
    add_column    :sphinx_admins, :value, :string
    remove_column :sphinx_admins, :from
    remove_column :sphinx_admins, :to
  end
end
