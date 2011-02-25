class ContainerTypesController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!, :except => [:index, :show]
end
