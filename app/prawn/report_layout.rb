class ReportLayout < PrawnLayout
  include DossiersHelper
  include I18nRailsHelpers

  # Creates the table headers for a report.
  def headers(report)
    column_headers = report[:columns].collect do |column|
      make_cell(:content => show_header_for_report(column))
    end

    year_count_headers = []

    if report.years_visible?
      year_count_headers = Dossier.years(report[:collect_year_count], report[:name]).collect do |year|
        make_cell(:content => year)
      end
    end

    headers = column_headers + year_count_headers
    default_table_width = 95
    table_width = default_table_width
    count = Array.new

    headers.each do |item|
      table_width = table_width + item.width
      if table_width > margin_box.width
        count << headers.index(item)
        table_width = default_table_width
      end
    end

    last_added_header = 0

    prepared_headers = count.inject([]) do |out, amount|
      if count.first.eql?amount
        last_added_header = amount - column_headers.count
        out << [column_headers + year_count_headers[0..last_added_header]]
      end

      out
    end

    if report.years_visible?
      year_header = year_count_headers[(last_added_header + 1)..year_count_headers.count]
      prepared_headers << [column_headers.first(2).flatten + year_header] if year_header.count > 0
    else
      prepared_headers << [column_headers.flatten]
    end

    [(count.empty? ? [[headers]] : prepared_headers), count]
  end
end
