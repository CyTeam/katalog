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
    
    return text
  end
  
  def availability_notes(dossier)
    # Collect availabilities
    availabilities = dossier.availability.compact

    partially = availabilities.size > 1

    notes = ""
    
    if availabilities.include?('intern')
      notes += availability_text('intern', partially)
    end
    if availabilities.include?('wait')
      notes += availability_text('wait', partially)
    end

    return notes.html_safe
  end
  
  def url_for_topic(topic)
    search_dossiers_url(:search => {:signature => topic.signature})
  end
  
  def link_to_topic(topic, options = {})
    link_to(topic, url_for_topic(topic), options)
  end

  # JS Highlighting
  def highlight_words(query, element = 'dossiers')
    return unless query.present?

    signatures, words, sentences = Dossier.split_search_words(query)

    content = ActiveSupport::SafeBuffer.new
    for word in (words + sentences)
      content += javascript_tag "$('##{element}').highlight('#{escape_javascript(word)}', 'match');"
    end
    
    return content
  end
end
