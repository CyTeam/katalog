class TopicDossier < Topic
  def find_parent
    TopicGeo.where(:signature => signature.split('.')[0..1].join('.')).first
  end

  # Importer
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
  end
end
