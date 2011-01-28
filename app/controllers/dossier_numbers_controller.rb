class DossierNumbersController < AuthorizedController
  def update
    @dossier_number = DossierNumber.find(params[:id])
    @dossier_number.amount = params[:amount]
    @dossier_number.save!

    render :nothing => true
  end
end
