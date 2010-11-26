class TopicGroup < Topic
  # Importer
  def self.import_filter
    /^[0-9]$/
  end
end
