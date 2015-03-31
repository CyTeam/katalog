require 'prawn/measurement_extensions'

class ReportLayout < PrawnLayout
  include DossiersHelper
  include I18nHelpers

  # Creates the table headers for a report.
  def headers(report)
    column_headers = report[:column_names].collect do |column|
      make_cell(head_cell(column))
    end

    year_count_headers = []

    if report.years_visible?
      years = Dossier.years(report[:collect_year_count], report[:name])

      year_count_headers = years.collect do |year|
        make_cell(year_head_cell(year))
      end
    end

    headers = column_headers + year_count_headers
    default_table_width = 95
    table_width = default_table_width
    count = []

    headers.each do |item|
      table_width = table_width + item.width
      if table_width > margin_box.width
        count << headers.index(item)
        table_width = default_table_width
      end
    end

    last_added_header = 0

    prepared_headers = count.inject([]) do |out, amount|
      if count.first.eql? amount
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

  def head_cell(value)
    options = { content: show_header_for_report(value) }

    case value
    when 'signature'
      options.merge!(width: 1.6.cm)
    when 'first_document_year'
      options.merge!(width: 2.5.cm)
    when 'keyword_text'
      options.merge!(width: 3.cm)
    when 'container_type'
      options.merge!(width: 0.75.cm)
    when 'location'
      options.merge!(width: 1.6.cm)
    when 'document_count'
      options.merge!(width: 1.cm, content: 'Total')
    end

    options
  end

  def year_head_cell(value)
    options = { content: value, align: :right }

    if value.include?('-')
      options.merge!(width: 1.83.cm)
    elsif value.include?('vor')
      options.merge!(width: 1.47.cm)
    elsif value.length == 4
      options.merge!(width: 1.cm)
    end

    options
  end
end
