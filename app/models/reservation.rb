class Reservation < ActiveRecord::Base
  belongs_to :dossier

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dossier_years, presence: true
  validates :pickup, presence: true

  validate :validate_pickup_date

  def year_selection=(inputs)
    self.dossier_years = inputs.reject(&:blank?).join(', ')
  end

  delegate :to_s, to: :dossier

  private


  def validate_pickup_date
    return unless pickup

    if pickup.cwday > 5
      errors.add :pickup, :weekend, day: I18n.l(pickup, format: '%A')
    else
      holidays = Holidays.on(pickup, :ch_zg)
      if holidays.present?
        errors.add :pickup, :holiday, name: holidays.first[:name]
      end
    end
  end
end
