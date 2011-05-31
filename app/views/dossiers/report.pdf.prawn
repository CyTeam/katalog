prawn_document(:page_size => 'A4', :page_layout => @report[:orientation].to_sym) do |pdf|

  # Gets the table data.
  items = @dossiers.map do |item|
    years = item.years_counts(@report[:collect_year_count], @report[:name])
    row = (@report[:columns] + (years.empty? ? Array.new : years)).inject([]) do |output, attr|
      if @report[:columns].include?attr
        output << pdf.make_cell(:content => show_column_for_report(item, attr, true).to_s)
      else
        output << pdf.make_cell(:content => attr[:count].to_s)
      end
    end

    row_styling(item.topic_type, row)
  end

  # Creates the table header.
  header_column = (@report[:columns] + Dossier.years(@report[:collect_year_count], @report[:name])).inject([]) do |output, attr|
    if @report[:columns].include?attr
      output << show_header_for_report(attr)
    else
      output << attr
    end
  end

  # Draws the title of the report.
  pdf.text @report[:title] if @report[:title]

  # Adds space after the title.
  pdf.move_down(20)

  # Draws the table with the content from the items.
  pdf.table([header_column] + items, :header => true,
                                     :width => pdf.margin_box.width,
                                     :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8}) do
    # General cell styling
    cells.valign = :top
    cells.border_width = 0.1

    # Headings styling
    row(0).font_style = :bold
    row(0).borders = [:bottom]

    # Columns width
    column(0).width = 70

    # Columns align
    columns(0..1).align = :left
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