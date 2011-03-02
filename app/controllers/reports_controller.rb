class ReportsController < AuthorizedController
  def attributes
    ['name', 'title', 'columns']
  end
end
