class TopicGeo < Topic
  def find_parent
    Topic.where(:signature => signature.split('.').first).first
  end

  # Importer
  def self.import_filter
    /^[0-9]{2}\.[0-9]$/
  end
end
