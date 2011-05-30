prawn_document(:page_size => 'A4', :page_layout => @report[:orientation].to_sym) do |pdf|

  items = @dossiers.map do |item|
    (@report[:columns] + (@report[:collect_year_count] ? item.years_counts(@report[:collect_year_count], @report[:name]) : nil)).inject([]) do |output, attr|
      if @report[:columns].include?attr
        output << show_column_for_report(item, attr, true)
      else
        output << attr[:count]
      end
    end
  end

  header_column = (@report[:columns] + Dossier.years(@report[:collect_year_count], @report[:name])).inject([]) do |output, attr|
    if @report[:columns].include?attr
      output << show_header_for_report(attr)
    else
      output << attr
    end
  end

  pdf.text @report[:title] if @report[:title]

  pdf.move_down(20)

  pdf.table items, :headers => header_column,
                   :row_colors => ["FFFFFF","DDDDDD"],
                   :column_widths => {0 => 70},
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