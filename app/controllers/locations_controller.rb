class LocationsController < AuthorizedController
  before_action :authenticate_user!, except: [:index, :show]

  private

  def location_params
    params.require(:location).permit(
      :title, :code, :address, :availability, :preorder
    )
  end
end
