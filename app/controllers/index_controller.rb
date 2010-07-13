class IndexController < ApplicationController
  def keyword
    @keyword_counts = Dossier.keyword_counts
  end

  def title
    @titles = Dossier.select(:title)
  end
end
