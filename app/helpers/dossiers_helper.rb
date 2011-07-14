module DossiersHelper
  def link_to_keyword(keyword, options = {})
    link_to(keyword, search_dossiers_path(:search => {:tag => keyword }), options)
  end

  def availability_text(availability, partially)
    title = t(availability, :scope => 'katalog.availability.title')
    if partially
      title = t('katalog.availability.partially') + " " + title
    end
    
    text = content_tag 'span', :class => "availability icon-availability_#{availability}-text", :title => title do
      title
    end
    
    text
  end
  
  def availability_notes(dossier)
    # Collect availabilities
    availabilities = dossier.availability.compact

    partially = availabilities.size > 1

    notes = ""
    
    if availabilities.include?('intern')
      notes += availability_text('intern', false)
    end
    if availabilities.include?('wait')
      notes += availability_text('wait', partially)
    end

    notes.html_safe
  end
  
  def url_for_topic(topic)
    if 'edit_report'.eql?action_name
      edit_report_dossiers_url(:search => {:signature => topic.signature})
    else
      search_dossiers_url(:search => {:signature => topic.signature})
    end
  end
  
  def link_to_topic(topic, options = {})
    link_to(topic, url_for_topic(topic), options)
  end

  def search_title
    if params[:search] and params[:search][:signature]
      return @dossiers.first.to_s
    else
      return t('katalog.search_for', :query => @query)
    end
  end

  # Reports
  # =======
  def show_header_for_report(column)
    case column
      when :document_count
        @document_count ? t('katalog.total_count', :count => number_with_delimiter(@document_count)) : t_attr(:document_count, Dossier)
      else
        t_attr(column.to_s, Dossier)
    end
  end
  
  def show_column_for_report(dossier, column, for_pdf = false)
    case column.to_s
      when 'title'
        for_pdf == true ? link_to(dossier.title, polymorphic_url(dossier)) : link_to(dossier.title, dossier, {'data-href-container' => 'tr'})
      when 'signature', 'first_document_year'
        value = dossier.send(column)

        value == nil ? '' : value
      when 'keyword_text'
        value = dossier.send(column)

        value == nil ? '' : value
      when 'container_type'
        dossier.container_types.collect{|t| t.code}.join(', ')
      when 'location'
        dossier.locations.collect{|l| l.code}.join(', ')
      when 'document_count'
        number_with_delimiter(dossier.document_count)
      when 'keywords'
        dossier.keywords.join(', ')
    end
  end

  # JS Highlighting
  def highlight_words(query, element = 'dossiers')
    return unless query.present?

    signatures, words, sentences = Dossier.split_search_words(query)
    # Highlight all alternatives for words
    words = SphinxAdmin.extend_words(words.flatten)

    content = ActiveSupport::SafeBuffer.new
    for word in (words + sentences)
      content += javascript_tag "$('##{element}').highlight('#{escape_javascript(word)}', 'match');"
    end
    
    content
  end

  def search_tips
    hints = t('katalog.search.tips.hints')
    content_tag :div, :id => 'search_tips' do
      content_tag :div, :id => 'search_tips_border' do
        content_tag :div, :id => 'search_tip' do
          hints[rand(hints.length)]
        end
      end
    end
  end

  def is_edit_report?
    'edit_report'.eql?action_name
  end

  # PDF
  # ===
  class Prawn < Prawn::Document
    def initialize(opts = {})
      super
      
      # Default Font
      font  'Helvetica'
      font_size 8
    end

    # Styles the row dependent on the topic type.
    def row_styling(item, row)
      row.map do |cell|
        cell.padding = [1, 5, 1, 5]
      end

      return row unless item.is_a?Topic

      row.map do |cell|
        case item.topic_type
          when :group
            cell.background_color = "96B1CD"
            cell.padding = [3, 5, 3, 5]
            cell.font_style = :bold
            cell.size = 10
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
end
