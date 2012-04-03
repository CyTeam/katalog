prawn_document(:page_size => 'A4',
               :filename => @report.title,
               :renderer => ReportLayout,
               :page_layout => @report[:orientation].to_sym) do |pdf|

  # Create the table headers
  headers, count = pdf.headers(@report)
  # Gets the table data.
  items = @dossiers.map do |item|
    columns = @report[:columns].collect do |column|
      pdf.make_cell(:content => show_column_for_report(item, column, true), :inline_format => true)
    end

    if @report.years_visible?
      years = item.years_counts(@report[:collect_year_count], @report[:name]).collect do |year|
        pdf.make_cell(:content => number_with_delimiter(year[:count]))
      end
      row = columns + years
    else
      row = columns
    end

    pdf.row_styling(item, row)
  end

  # Use local variable as instance vars aren't accessible
  columns = @report[:columns]

  first_count = 0

  headers.each do |header|
    last_count = count[headers.index(header)]
    last_count = items.first.count if !last_count.presence && items.first

    rows = items.inject([]) do |out, item|
      unless headers.first.eql?(header)
        out << item.slice(0..1) + item.slice(first_count..last_count)
      else
        out << item.slice(first_count..last_count)
      end

      out
    end

    first_count = last_count + 1 if last_count


    # Draw the title
    pdf.h1 @report[:title]

    table = header + rows

    pdf.table table, :header => true, :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8} do
      # General cell styling
      cells.padding      = [1, 5, 1, 5]
      cells.valign       = :top
      cells.border_width = 0
      # Headings styling
      row(0).font_style = :bold
      row(0).background_color = 'E1E6EC'
      # Columns align
      columns(0..1).align = :left
      columns(0).align = :left
      # Right align document count
      columns(columns.index(:document_count)).align = :right
      # Styles for year columns
      year_columns = columns(columns.size..headers.first.size)
      year_columns.align = :right
    #  year_columns.width = 45
      # Columns width
      #column(0).width = 50
    end

    # Footer
    pdf.page_footer
    unless headers.last.eql?header
      pdf.start_new_page
    end
  end
end
