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

  def highlight_words(words)
    return unless words.present?

    signatures, words = Dossier.split_search_words(params[:search][:text])

    content = ActiveSupport::SafeBuffer.new
    for word in words
      content += javascript_tag "Element.highlight($('dossiers'), '#{escape_javascript(word)}', 'match');"
    end
    
    return content
  end
end
