class SearchReplacesController < AuthorizedController
  def index
    @search_replace = SearchReplace.new
  end

  def create
    @search_replace = SearchReplace.new(params[:search_replace])
    if @search_replace.valid?
      @search_replace.do
      flash[:notice] = 'done'
    else
      flash[:error] = 'failed'
    end

    redirect_to :action => :index
  end
end
