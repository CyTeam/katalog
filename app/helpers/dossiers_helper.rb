module DossiersHelper
  def link_to_keyword(keyword, options = {})
    link_to(keyword, search_dossiers_path(:search => {:tag => keyword }), options)
  end

  def url_for_topic(topic)
    search_dossiers_url(:search => {:signature => topic.signature})
  end
  
  def link_to_topic(topic, options = {})
    link_to(topic, url_for_topic(topic), options)
  end

  def highlight_words(query, element = 'dossiers')
    return unless query.present?

    signatures, words, sentences = Dossier.split_search_words(query)

    content = ActiveSupport::SafeBuffer.new
    for word in (words + sentences)
      content += javascript_tag "Element.highlight($('#{element}'), '#{escape_javascript(word)}', 'match');"
    end
    
    return content
  end
end
