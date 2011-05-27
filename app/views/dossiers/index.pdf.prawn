prawn_document do |pdf|

  items = @dossiers.map do |item|
    [
      item.signature,
      item.title,
      item.document_count
    ]
  end

  pdf.table items, :headers => [I18n.t('activerecord.attributes.dossier.signature'), I18n.t('activerecord.attributes.dossier.title'), I18n.t('activerecord.attributes.dossier.document_count')],
                   :row_colors => ["FFFFFF","DDDDDD"],
                   :column_widths => {0 => 70, 1 => pdf.margin_box.width - 70 - 150, 2 => 150},
                   :width => pdf.margin_box.width,
                   :position => :center,
                   :align => {0 => :left, 1 => :left, 2 => :right},
                   :align_headers => :left


  pdf.repeat :all do
    pdf.stroke_line [pdf.bounds.right - 50, 0], [pdf.bounds.right, 0]
  end

  pdf.number_pages "<page>", :at => [pdf.bounds.right - 150, -5],
                             :width => 150,
                             :align => :right,
                             :page_filter => :all,
                             :start_count_at => 1,
                             :total_pages => pdf.page_count

end