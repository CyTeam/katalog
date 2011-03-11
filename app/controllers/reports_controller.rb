class ReportsController < AuthorizedController
  def attributes
    ['name', 'title', 'columns']
  end

  def edit
    edit!{ report_path }
  end
end
