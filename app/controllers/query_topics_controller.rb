class QueryTopicsController < AuthorizedController
  def index
    @attributes = [:signature, :title, :query]

    index!
  end

  def show
    dossiers

    show!
  end

  def edit
    dossiers

    edit!
  end

  private

  def dossiers
    @dossiers = resource.dossiers unless resource.dossiers.empty?
  end
end