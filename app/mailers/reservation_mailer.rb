# encoding: UTF-8

class ReservationMailer < ActionMailer::Base
  default from: Settings.mail.reservation.sender

  def user_email(reservation)
    @reservation = reservation

    mail(
      to: Settings.mail.reservation.sender,
      reply_to: reservation.email,
      subject: "#{I18n.t('activerecord.attributes.reservation.title')}: #{@reservation.dossier}",
      cc: reservation.email
    )
  end
end
