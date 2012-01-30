module DossiersHelper
  def link_to_keyword(keyword, options = {})
    link_to(keyword, search_dossiers_path(:search => {:text => keyword}), options)
  end

  def availability_text(availability, partially, js_popup = true)
    title = t(availability, :scope => 'katalog.availability.title')
    if partially
      title = t('katalog.availability.partially') + " " + title
    end

    text = content_tag 'span', :class => "availability icon-availability_#{availability}-text", :title => (js_popup ? title : '') do
      title
    end

    text
  end

  def availability_notes(dossier)
    # Collect availabilities
    availabilities = availabilities(dossier)
    notes = ""
    notes += availability_text('intern', false) if availabilities.include?('intern')
    notes += availability_text('warning', (availabilities.size > 1)) if availabilities.include?('wait')

    notes.html_safe
  end

  def waiting_for?(dossier)
    availabilities = availabilities(dossier)
    
    availabilities.include?('wait') ? true : false
  end

  def url_for_topic(topic)
    return query_topic_path(topic) if topic.kind_of?(QueryTopic)

    if 'edit_report'.eql?action_name
      edit_report_dossiers_path(:search => {:signature => topic.signature})
    else
      search_dossiers_path(:search => {:signature => topic.signature})
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
      when 'container_type'
        dossier.container_types.collect{|t| t.code}.join(', ')
      when 'location'
        dossier.locations.collect{|l| l.code}.join(', ')
      when 'document_count'
        number_with_delimiter(dossier.document_count)
      when 'keywords'
        dossier.keywords.join(', ')
      else
        dossier.send(column).to_s
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
      content += javascript_tag "$('##{element}').highlight('#{escape_javascript(word)}', 'match')"
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

  def split_decades(numbers)
    splitted_numbers = []
    decades = (199..(DateTime.now.year.to_s[0..2].to_i))

    decades.each do |decade|
      splitted_numbers << numbers.find_all {|n| n.period.include?(decade.to_s) }
    end
    
    splitted_numbers
  end

  def default_periods_collection
    DossierNumber.default_periods.collect do |d|
      from = d[:from].present? ? d[:from].year : ""
      
      [ "#{from} - #{d[:to].year}", d[:to].year ] if d[:to]
    end
  end

  private

  def availabilities(dossier)
    dossier.availability.compact
  end
end
