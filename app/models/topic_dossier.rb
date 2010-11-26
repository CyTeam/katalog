class TopicDossier < Topic
  # Importer
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
  end
end
