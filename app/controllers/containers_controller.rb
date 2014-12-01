class ContainersController < AuthorizedController
  # Authentication
  before_action :authenticate_user!, except: [:index, :search, :show]

  # Responders
  respond_to :html, :js
end
