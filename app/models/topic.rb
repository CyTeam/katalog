class Topic < ActiveRecord::Base
  # Importer
  def self.import_filter
    /^[0-9]{2}$/
  end
end
