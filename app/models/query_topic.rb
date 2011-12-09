class QueryTopic < Topic
  def dossiers
    Dossier.by_text(self.query)
  end

  def document_count
    0
  end
end