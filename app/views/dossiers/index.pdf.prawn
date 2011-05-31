prawn_document(:page_size => 'A4') do |pdf|

  # Table content creation.
  items = table_data(pdf, @dossiers)

  # Table header creation.
  headers = [[t_attr(:signature), t_attr(:title), t_attr(:document_count)]]

  # Table creation.
  pdf.table headers + items, :header => true,
                             :width => pdf.margin_box.width,
                             :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8 } do

    # General cell styling
    cells.valign = :top
    cells.border_width = 0.1

    # Headings styling
    row(0).font_style = :bold
    row(0).borders = [:bottom]

    # Columns width
    column(0).width = 70
    column(2).width = 150

    # Columns align
    columns(0..1).align = :left
    column(2).align     = :right
  end

  # Draws the line above the page number on each page.
  pdf.repeat :all do
    pdf.stroke_line [pdf.bounds.right - 50, 0], [pdf.bounds.right, 0]
  end

  # Draws the page number on each page.
  pdf.number_pages "<page>", :at => [pdf.bounds.right - 150, -5],
                             :width => 150,
                             :align => :right,
                             :page_filter => :all,
                             :start_count_at => 1,
                             :total_pages => pdf.page_count

end