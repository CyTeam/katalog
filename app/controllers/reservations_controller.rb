# encoding: UTF-8

class ReservationsController < AuthorizedController
  def new
    @dossier = Dossier.find(params[:dossier_id])
    @reservation = Reservation.new(pickup: DateTime.tomorrow, dossier: @dossier)
    @year = params[:year]

    new!
  end

  def create
    create! do |success, _failure|
      success.html do
        ReservationMailer.user_email(@reservation).deliver
        flash[:notice] = I18n.translate('katalog.reservation_send')

        redirect_to dossier_path(@reservation.dossier)
      end
    end
  end
end
