prawn_document(:page_size => 'A4', :filename => @report.title, :renderer => PrawnLayout, :page_layout => @report[:orientation].to_sym) do |pdf|

  # Creates the table header.
  column_headers = @report[:columns].collect do |column|
    pdf.make_cell(:content => show_header_for_report(column))
  end

  year_count_headers = Dossier.years(@report[:collect_year_count], @report[:name]).collect do |year|
    pdf.make_cell(:content => year)
  end

  table = 0
  count = 0

  [column_headers + year_count_headers].first.each do |item|
    unless table > pdf.margin_box.width
      table = table + item.width
      count = [column_headers + year_count_headers].first.index(item)
    end
  end

  headers = [column_headers + year_count_headers[0..(count-column_headers.count)]]

  # Gets the table data.
  items = @dossiers.map do |item|
    columns = @report[:columns].collect do |column|
      pdf.make_cell(:content => show_column_for_report(item, column, true), :inline_format => true)
    end

    years = item.years_counts(@report[:collect_year_count], @report[:name]).collect do |year|
      pdf.make_cell(:content => number_with_delimiter(year[:count]))
    end

    row = columns + years

    pdf.row_styling(item, row)
  end

  # Draw the title
  pdf.h1 @report[:title]

  # Use local variable as instance vars aren't accessible
  columns = @report[:columns]

  # Draws the table with the content from the items.
  pdf.table headers + items, :header => true,
                             :width => pdf.margin_box.width,
                             :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8} do

    # General cell styling
    cells.padding      = [1, 5, 1, 5]
    cells.valign       = :top
    cells.border_width = 0

    # Headings styling
    row(0).font_style = :bold
    row(0).background_color = 'E1E6EC'

    # Columns width
    column(0).width = 50

    # Columns align
    columns(0..1).align = :left

    # Right align document count
    columns(columns.index(:document_count)).align = :right

    # Styles for year columns
    year_columns = columns(columns.size..headers.first.size)
    year_columns.align = :right
    year_columns.width = 45
  end

  # Footer
  pdf.page_footer
end
