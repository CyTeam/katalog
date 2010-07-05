class ContainerTypesController < InheritedResources::Base
  protected
  def collection
    @container_types ||= end_of_association_chain.paginate(:page => params[:page])
  end
end
