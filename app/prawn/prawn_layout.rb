class PrawnLayout < Prawn::Document
  def initialize(opts = {})
    super
    
    # Default Font
    font  'Helvetica'
    font_size 8
  end

  # Styles the row dependent on the topic type.
  def row_styling(item, row)
    return row unless item.is_a? Topic

    row.map do |cell|
      case item.topic_type
        when :group
          cell.background_color = "96B1CD"
          cell.padding_top      = 3
          cell.padding_bottom   = 3
          cell.font_style       = :bold
          cell.size             = 10
        when :main
          cell.background_color = "E1E6EC"
        when :geo
          cell.background_color = "C8B7B7"
        when :detail
          cell.background_color = "E9DDAF"
      end
    end

    row
  end

  # Creates the title with bottom space to the next element.
  def h1(title)
    if title
      # User multi byte handling for proper upcasing of umlaute
      # Draws the title of the report
      text title.mb_chars.upcase, :size => 16, :color => "E1E6EC"

      # Adds space after the title
      move_down(5)
    end
  end

  # Footer
  # =====
  # Draws the line above the page number on each page.
  def page_footer
    repeat :all do
      stroke_line [bounds.right - 50, 0], [bounds.right, 0]
    end

    page_footer_number
  end

  # Draws the page number on each page.
  def page_footer_number
    number_pages "<page>", :at => [bounds.right - 150, -5],
                               :width => 150,
                               :align => :right,
                               :page_filter => :all,
                               :start_count_at => 1,
                               :total_pages => page_count
  end
end
