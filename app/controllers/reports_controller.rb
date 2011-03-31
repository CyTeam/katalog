class ReportsController < AuthorizedController
  def attributes
    ['title', 'columns', 'public']
  end

  def edit
    edit!{ report_path }
  end

  def show
    if params[:get_preview]
      @report = Report.new(params[:report])
      render :partial => 'show'
      return
    end

    show!
  end

  def update
    expire_fragment('page_actions')
    update!
  end
end
