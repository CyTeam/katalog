class QueryTopic < Topic
  def dossiers
    return nil unless self.query.present?

    dossiers = Dossier.by_text(self.query, :without => {:type => self.class.to_s})

    dossiers.compact
  end

  def document_count
    0
  end
end