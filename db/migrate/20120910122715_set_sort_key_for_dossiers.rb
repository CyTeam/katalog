class SetSortKeyForDossiers < ActiveRecord::Migration
  def up
    Dossier.transaction do
      Dossier.find_each do |d|
         d.update_column(:sort_key, d.calculate_sort_key)
      end
    end
  end
end
