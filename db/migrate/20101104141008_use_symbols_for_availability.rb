# encoding: utf-8

class UseSymbolsForAvailability < ActiveRecord::Migration
  def self.up
    Location.update_all("availability = 'ready'", "availability = 'Diese Dokumente sind bei uns sofort einsehbar.'")
    Location.update_all("availability = 'wait'", "availability = 'Wünschen Sie ein Dokument von hier, beachten Sie bitte die Wartezeit von einem Tag.'")
    Location.update_all("availability = 'intern'", "code IN ('ML', 'DB')")
  end

  def self.down
  end
end
