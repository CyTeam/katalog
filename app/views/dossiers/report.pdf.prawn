prawn_document(:page_size => 'A4', :filename => @report.title, :renderer => DossiersHelper::Prawn, :page_layout => @report[:orientation].to_sym) do |pdf|

  # Gets the table data.
  items = @dossiers.map do |item|
    years = item.years_counts(@report[:collect_year_count], @report[:name])
    row = (@report[:columns] + (years.empty? ? Array.new : years)).inject([]) do |output, attr|
      if @report[:columns].include? attr
        output << pdf.make_cell(:content => show_column_for_report(item, attr, true).to_s, :inline_format => true)
      else
        output << pdf.make_cell(:content => attr[:count].to_s)
      end
    end

    pdf.row_styling(item, row)
  end

  # Creates the table header.
  column_headers = @report[:columns].collect do |column|
    show_header_for_report(column)
  end

  year_count_headers = Dossier.years(@report[:collect_year_count], @report[:name]).collect do |year|
    year
  end
  headers = [column_headers + year_count_headers]

  # Draw the title
  pdf.h1 @report[:title]

  # Use local variable as instance vars aren't accessible
  columns = @report[:columns]

  # Draws the table with the content from the items.
  pdf.table headers + items, :header => true,
                             :width => pdf.margin_box.width,
                             :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 8} do

    # General cell styling
    cells.valign = :top
    cells.border_width = 0

    # Headings styling
    row(0).font_style = :bold
    row(0).background_color = 'E1E6EC'

    # Columns width
    column(0).width = 50

    # Columns align
    columns(0..1).align = :left

    columns(columns.index(:document_count)).align = :right
    columns(columns.size..headers.first.size).align = :right
  end

  # Footer
  pdf.page_footer
end
