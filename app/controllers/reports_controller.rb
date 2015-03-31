class ReportsController < AuthorizedController
  def attributes
    %w(title column_names public)
  end

  def edit
    edit! { report_path }
  end

  def show
    show!
  end

  def preview
    @report = Report.new(report_params)
    render partial: 'show'
  end

  private

  def report_params
    params.require(:report).permit(
      :name, :title, :level, :orientation, :years_visible,
      :collect_year_count, :public, column_names: []
    )
  end
end
