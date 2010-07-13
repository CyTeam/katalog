module DossiersHelper
  def link_to_keyword(keyword)
    link_to keyword, dossiers_path(:dossier => {:tag => keyword })
  end
end
