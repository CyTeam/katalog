class VersionsController < AuthorizedController
  # Authentication
  before_filter :authenticate_user!

  def index
    if params[:dossier_id]
      dossiers = Dossier.find(params[:dossier_id])
      @versions = dossiers.versions
      dossiers.numbers.each do |n|
        n.versions.each do |v|
          @versions << v
        end
      end
    end

    index!
  end
end
