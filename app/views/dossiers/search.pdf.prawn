prawn_document do |pdf|
  # [I18n.t('activerecord.attributes.dossier.signature'), I18n.t('activerecord.attributes.dossier.title'), I18n.t('activerecord.attributes.dossier.document_count')]
  # The first line is the header
  items = @dossiers.map do |item|
    [
      item.signature,
      item.title,
      item.document_count
    ]
  end

  pdf.table items, :header => true, :row_colors => ["FFFFFF","DDDDDD"]
end