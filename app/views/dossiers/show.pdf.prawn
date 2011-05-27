prawn_document(:page_size => 'A4') do |pdf|
  pdf.text @dossier.to_s
end