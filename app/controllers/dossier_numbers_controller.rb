class DossierNumbersController < AuthorizedController
  respond_to :json, only: :create

  def update
    @dossier_number = DossierNumber.find(params[:id])
    @dossier_number.amount = params[:amount]
    @dossier_number.save!

    render nothing: true
  end

  def create
    create! do |format|
      format.json { render json: @dossier_number.id }
    end
  end
end
