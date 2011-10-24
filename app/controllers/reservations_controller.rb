class ReservationsController < AuthorizedController
  
  def new
    @dossier = Dossier.find(params[:dossier_id])
    @reservation = Reservation.new(:pickup => DateTime.tomorrow, :dossier => @dossier)
    
    new!
  end
  
  def create
    create! { dossier_path(@reservation.dossier) }
  end
end
