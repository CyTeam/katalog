class ContainerTypesController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :show]

  protected
  def collection
    @container_types ||= end_of_association_chain.paginate(:page => params[:page])
  end
end
