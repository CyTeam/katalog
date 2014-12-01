class LocationsController < AuthorizedController
  before_filter :authenticate_user!, except: [:index, :show]

  private

  def location_params
    params.require(:location).permit(
      :title, :code, :address, :availability, :preorder
    )
  end
end
