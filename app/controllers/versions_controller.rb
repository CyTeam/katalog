class VersionsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def index
    index!
  end
end
