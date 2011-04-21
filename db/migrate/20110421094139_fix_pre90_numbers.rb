class FixPre90Numbers < ActiveRecord::Migration
  def self.up
    DossierNumber.where(:from => '0000-01-01', :to => '0000-12-31').update_all("`from` = NULL, `to` = '1989-12-31'")
  end

  def self.down
  end
end
