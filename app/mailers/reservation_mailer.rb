class ReservationMailer < ActionMailer::Base
  default :from => "reservation@dokuzug.ch"
  
  def user_email(reservation)
    @reservation = reservation
    
    mail(:to => 'info@dokuzug.ch', :subject => "#{I18n.t('activerecord.models.reservation')}: #{@reservation.dossier}")
  end
end
