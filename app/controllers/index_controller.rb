class IndexController < ApplicationController
  def title
    @titles = Dossier.select(:title)
  end
end
