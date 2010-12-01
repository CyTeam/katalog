class LocationsController < InheritedResources::Base
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :show]

  protected
  def collection
    @locations ||= end_of_association_chain.paginate(:page => params[:page])
  end
end
