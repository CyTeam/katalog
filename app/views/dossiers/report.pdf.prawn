prawn_document do |pdf|
  @dossiers.each do |dossier|
    pdf.text dossier.to_s
  end
end