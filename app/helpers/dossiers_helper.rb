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
end
