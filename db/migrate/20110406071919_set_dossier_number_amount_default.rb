class SetDossierNumberAmountDefault < ActiveRecord::Migration
  def self.up
    change_column_default :dossier_numbers, :amount, 0

    DossierNumber.update_all(['amount = ?', 0], 'amount IS NULL')
  end

  def self.down
  end
end
