# encoding: UTF-8

class ReservationMailer < ActionMailer::Base
  default from: Settings.mail.reservation.sender

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
      from: Settings.mail.reservation.internal_sender,
      to: Settings.mail.reservation.sender,
      subject: "#{I18n.t('activerecord.attributes.reservation.title')}: #{@reservation.dossier}"
    )
  end
end
