class SearchReplacesController < AuthorizedController
  def index
    @search_replace = SearchReplace.new
  end

  def create
    @search_replace = SearchReplace.new(params[:search_replace])
    if @search_replace.valid?
      amount = @search_replace.do
      flash[:notice] = t('katalog.search_replace.done', :amount => amount)
    else
      flash[:error] = t('katalog.search_replace.failed')
    end

    redirect_to :action => :index
  end
end
