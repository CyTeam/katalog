class LocationsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :show]

  def attributes
    ['title', 'code', 'address', 'availability']
  end
end
