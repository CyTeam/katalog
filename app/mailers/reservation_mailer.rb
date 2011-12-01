class ReservationMailer < ActionMailer::Base
  default :from => "info@doku-zug.ch"

  def user_email(reservation)
    @reservation = reservation
    
    mail(:to => 'info@doku-zug.ch', :subject => "#{I18n.t('activerecord.models.reservation')}: #{@reservation.dossier}")
  end
end
