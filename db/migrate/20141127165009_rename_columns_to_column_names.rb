class RenameColumnsToColumnNames < ActiveRecord::Migration
  def change
    rename_column :reports, :columns, :column_names
  end
end
