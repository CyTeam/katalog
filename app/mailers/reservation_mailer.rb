# encoding: UTF-8

class ReservationMailer < ActionMailer::Base
  default from: Settings.mail.sender, reply_to: Settings.mail.recipient

  def user_email(reservation)
    @reservation = reservation

    mail(
      to: reservation.email,
      subject: "#{I18n.t('activerecord.attributes.reservation.title')}: #{@reservation.dossier}"
    )
  end

  def editor_email(reservation)
    @reservation = reservation

    mail(
      to: Settings.mail.recipient,
      subject: "#{I18n.t('activerecord.attributes.reservation.title')}: #{@reservation.dossier}"
    )
  end
end
