prawn_document(:page_size => 'A4') do |pdf|

  items = @dossiers.map do |item|
    row = [
      pdf.make_cell(:content => item.signature.to_s),
      pdf.make_cell(:content => item.title.to_s),
      pdf.make_cell(:content => item.document_count.to_s)
    ]

    # Row styling
    row.map do |cell|
      case item.topic_type
      when :group
        cell.background_color = "96B1CD"
      when :main
        cell.background_color = "E1E6EC"
      when :geo
        cell.background_color = "C8B7B7"
      when :detail
        cell.background_color = "E9DDAF"
      end
    end

    row
  end

  headers = [[t_attr(:signature), t_attr(:title), t_attr(:document_count)]]

pdf.table headers + items, :header => true,
                           :width => pdf.margin_box.width,
                           :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8 } do

  # General
  cells.valign = :top
  cells.border_width = 0.1

  # Headings
  row(0).font_style = :bold
  row(0).borders = [:bottom]

  # Columns
  column(0).width = 70
  column(2).width = 150

  columns(0..1).align = :left
  column(2).align     = :right
end

#  pdf.table items, :headers => [I18n.t('activerecord.attributes.dossier.signature'), I18n.t('activerecord.attributes.dossier.title'), I18n.t('activerecord.attributes.dossier.document_count')],
#                   :row_colors => ["FFFFFF","DDDDDD"],
#                   :column_widths => {0 => 70, 1 => pdf.margin_box.width - 70 - 150, 2 => 150},
#                   :width => pdf.margin_box.width,
#                   :position => :center
#                   :align => {0 => :left, 1 => :left, 2 => :right},
#                   :align_headers => :left


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