class VersionsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def index
    if params[:dossier_id]
      @versions = Dossier.find(params[:dossier_id]).versions
    end

    index!
  end
end
