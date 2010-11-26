class TopicGeo < Topic
  # Importer
  def self.import_filter
    /^[0-9]{2}\.[0-9]$/
  end
end
