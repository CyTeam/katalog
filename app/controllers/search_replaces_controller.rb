class SearchReplacesController < AuthorizedController
  def index
    @search_replace = SearchReplace.new
  end

  def create
    @search_replace = SearchReplace.new(params[:search_replace])
    if @search_replace.valid?
      @changed_objects = @search_replace.do
      if @changed_objects.present?
        flash[:notice] = t('katalog.search_replace.done', amount: @changed_objects.count).html_safe
      else
        flash[:notice] = t('katalog.search_replace.none')
      end
    end

    render :index
  end
end
