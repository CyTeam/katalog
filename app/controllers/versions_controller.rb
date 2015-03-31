class VersionsController < AuthorizedController
  include VersionsHelper
  # Authentication
  before_action :authenticate_user!

  def attributes
    %w(item_type object changed_from changed_at action)
  end

  def show
    @version = Version.find(params[:id])

    @current_item = @version.current_item
    @previous_item = @version.previous_item

    @versions = @version.versions.reorder('created_at DESC').paginate(page: params[:page])

    show!
  end

  def index
    if params[:dossier_id]
      dossier = Dossier.find(params[:dossier_id])
      @versions = Version.where("(item_type = 'Dossier' AND item_id = ?) OR (item_type = 'DossierNumber' AND item_id IN (?))", dossier.id, dossier.number_ids)
    elsif params[:type]
      @versions = Version.where('item_type = ?', params[:type])
    else
      @versions = Version.where(nested_model: false)
    end

    @versions = @versions.reorder('created_at DESC').paginate(page: params[:page])

    index!
  end

  def revert
    @version = Version.find(params[:id])
    @version.revert

    redirect_to :back
  end
end
