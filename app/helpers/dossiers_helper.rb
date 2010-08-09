module DossiersHelper
  def link_to_keyword(keyword)
    link_to keyword, dossiers_path(:dossier => {:tag => keyword })
  end

  def url_for_topic(topic)
    dossiers_url(:dossier => {:signature => topic.signature})
  end
  
  def link_to_topic(topic)
    link_to(topic, url_for_topic(topic))
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
