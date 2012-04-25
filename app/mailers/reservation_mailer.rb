class ReservationMailer < ActionMailer::Base
  default :from => RESERVATION_EMAIL_SENDER # This constant is definied in mail initializer.

  def user_email(reservation)
    @reservation = reservation
    
    mail(
      :to       => RESERVATION_EMAIL_RECIPIENT,
      :reply_to => reservation.email,
      :subject  => "#{I18n.t('activerecord.attributes.reservation.title')}: #{@reservation.dossier}",
      :cc      => reservation.email
    )
  end
end
