# encoding: UTF-8

class ReportsController < AuthorizedController
  def attributes
    %w(title columns public)
  end

  def edit
    edit! { report_path }
  end

  def show
    show!
  end

  def preview
    @report = Report.new(params[:report])
    render partial: 'show'
  end
end
