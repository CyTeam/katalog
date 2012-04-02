class ReportLayout < PrawnLayout
  include DossiersHelper
  include I18nRailsHelpers

  def headers(report)
    # Creates the table header.
    column_headers = report[:columns].collect do |column|
      make_cell(:content => show_header_for_report(column))
    end

    year_count_headers = []

    if report.years_visible?
      year_count_headers = Dossier.years(report[:collect_year_count], report[:name]).collect do |year|
        make_cell(:content => year)
      end
    end

    default_table_width = 95
    table_width = default_table_width
    count = Array.new

    [column_headers + year_count_headers].first.each do |item|
      table_width = table_width + item.width
      if table_width > margin_box.width
        count << [column_headers + year_count_headers].first.index(item)
        table_width = default_table_width
      end
    end

    last_added_header = 0

    headers = count.inject([]) do |out, amount|
      if count.first.eql?amount
        last_added_header = amount - column_headers.count
        out << [column_headers + year_count_headers[0..last_added_header]]
      end

      out
    end

    if report.years_visible?
      year_header = year_count_headers[last_added_header..year_count_headers.count]
      headers << [column_headers.first(2).flatten + year_header] if year_header.count > 0
    else
      headers << [column_headers.flatten]
    end

    headers
  end
end
