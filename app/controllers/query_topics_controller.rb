class QueryTopicsController < AuthorizedController
  def index
    @attributes = [:signature, :title, :query]

    index!
  end
end