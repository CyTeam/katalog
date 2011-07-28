prawn_document(:page_size => 'A4', :renderer => PrawnLayout) do |pdf|

  # Table content creation.
  items = @dossiers.map do |item|
    row = [
      pdf.make_cell(:content => item.signature.to_s),
      pdf.make_cell(:content => link_to(item.title, polymorphic_url(item)).to_s, :inline_format => true),
      pdf.make_cell(:content => number_with_delimiter(item.document_count))
    ]

    pdf.row_styling(item, row)
  end

  # Table header creation.
  headers = [[t_attr(:signature), t_attr(:title), t_attr(:document_count)]]

  # Draw the title
  pdf.h1 t('katalog.overview')

  # Table creation.
  pdf.table headers + items, :header => true,
                             :width => pdf.margin_box.width,
                             :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8 } do

    # General cell styling
    cells.valign = :top
    cells.border_width = 0

    # Headings styling
    row(0).font_style = :bold
    row(0).background_color = 'E1E6EC'

    # Columns width
    column(0).width = 50
    column(2).width = 150

    # Columns align
    columns(0..1).align = :left
    column(2).align     = :right
  end

  # Footer
  pdf.page_footer
end
