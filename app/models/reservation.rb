class Reservation < ActiveRecord::Base
  
  belongs_to :dossier
  
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :dossier_years, :presence => true
  validates :pickup, :presence => true
  
  def year_selection=(inputs)
    self.dossier_years = inputs.reject{|input| input.blank? }.join(', ')
  end
end
