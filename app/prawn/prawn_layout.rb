# encoding: UTF-8

class PrawnLayout < Prawn::Document
  def initialize(opts = {})
    super

    # Default Font
    font 'Helvetica'
    font_size 8
  end

  # Styles a html text so that a list is shown.
  def list(html_input)
    list = html_input.split(/<ul>(.*)<\/ul>/m)

    list.inject([]) do |out, line|
      unless line.include?('<li>')
        out << line.gsub("\t", '').gsub(/<li>/m, '- ').gsub(/<\/li>/m, '') .gsub('&nbsp;', ' ')
      else
        prepared_list = "\n" + line.gsub("\t", '').gsub('&nbsp;', ' ').split.join.gsub(/<li>/m, '- ').gsub(/<\/li>/m, "\n")
        out << prepared_list[0..-2]
      end

      out
    end.join('')
  end

  # Styles the row dependent on the topic type.
  def row_styling(item, row)
    return row unless item.is_a? Topic

    row.map do |cell|
      case item.topic_type
        when :topic_group
          cell.background_color = '96B1CD'
          cell.padding_top      = 3
          cell.padding_bottom   = 3
          cell.font_style       = :bold
          cell.size             = 10
        when :main
          cell.background_color = 'E1E6EC'
        when :geo
          cell.background_color = 'C8B7B7'
        when :detail
          cell.background_color = 'E9DDAF'
      end
    end

    row
  end

  # Creates the title with bottom space to the next element.
  def h1(title)
    if title
      # User multi byte handling for proper upcasing of umlaute
      # Draws the title of the report
      text title.mb_chars.upcase, size: 16

      # Adds space after the title
      move_down(5)
    end
  end

  # Footer
  # =====
  # Draws the line above the page number on each page.
  def page_footer(user = nil)
    repeat :all do
      image Rails.root.join('app/assets/images/doku-zug.ch/logo_white.png'), at: [bounds.right - 70, bounds.top + 10], width: 70

      stroke_line [bounds.right - 50, 0], [bounds.right, 0]

      bounding_box [bounds.left, 0], width: 150, height: 40 do
        font_size 7 do
          fill_color '96B1CD'
          text 'St. Oswaldsgasse 16, Postfach 1146, 6301 Zug'
          text 'Telefon 041 726 81 81, Fax 041 726 81 88'
          text 'info@doku-zug.ch, www.doku-zug.ch'
        end
      end

      bounding_box [bounds.left + 325, 0], width: 150, height: 40 do
        font_size 7 do
          fill_color '96B1CD'
          text 'gedruckt am: ' + Date.today.to_s
          text 'gedruckt von: ' + user.username if user
        end
      end

      bounding_box [bounds.left + 200, 0], width: 150, height: 40 do
        font_size 7 do
          fill_color '96B1CD'
          text 'Öffnungszeiten:'
          text 'Mo / Di / Mi / Fr 10 - 18 Uhr'
          text 'Do 10 - 20 Uhr'
        end
      end
    end

    page_footer_number
  end

  # Draws the page number on each page.
  def page_footer_number
    number_pages '<page>', at: [bounds.right - 150, -5],
                           width: 150,
                           align: :right,
                           page_filter: :all,
                           start_count_at: 1,
                           total_pages: page_count
  end
end
