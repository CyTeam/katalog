class SetSortTitleOnDossiers < ActiveRecord::Migration
  def up
    Dossier.transaction do
      Dossier.find_each do |d|
         d.update_column(:sort_title, d.calculate_sort_title)
      end
    end
  end
end
