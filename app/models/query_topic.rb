class QueryTopic < Topic
  def dossiers
    Dossier.by_text(self.query) if self.query.present?
  end

  def document_count
    0
  end
end