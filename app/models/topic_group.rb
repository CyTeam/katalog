class TopicGroup < Topic
  def find_parent
    nil
  end

  # Importer
  def self.import_filter
    /^[0-9]$/
  end
end
