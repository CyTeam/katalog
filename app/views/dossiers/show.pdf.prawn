prawn_document(:page_size => 'A4') do |pdf|
  # Style
  font pdf

  pdf_title pdf, @dossier.to_s

  # Footer
  page_footer(pdf)
end
