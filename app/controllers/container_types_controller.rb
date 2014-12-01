class ContainerTypesController < AuthorizedController
  before_filter :authenticate_user!, except: [:index, :show]

  private

  def container_type_params
    params.require(:container_type).permit(
      :title, :code, :description
    )
  end
end
