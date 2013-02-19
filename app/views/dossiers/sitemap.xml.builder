xml.instruct!
xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
  @dossiers.each do |dossier|
    xml.url do
      xml.loc url_for(:controller => 'dossiers', :action => 'show', :id => dossier.id, :only_path => false)
    end
  end
end
