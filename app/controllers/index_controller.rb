class IndexController < ApplicationController
  def keyword
    @index = Dossier.keyword_counts.order(:name).paginate(:per_page => 50, :page => params[:page])
  end

  def title
    @titles = Dossier.select(:title)
  end
end
