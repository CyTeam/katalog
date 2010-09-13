class DossierNumber < ActiveRecord::Base
  # Associations
  belongs_to :dossier

  # Scopes
  scope :present, where("amount > 0")
  
  def to_s(format = :default)
    "#{period(format)}: #{amount}"
  end
  
  def self.from_s(value)
    # Convert integers to string
    value = value.to_s
    
    if value =~ /-/
      return value.split('-').map{|year| year.present? ? year.to_i : nil}
    else
      year = value.to_i
      return [year, year]
    end
  end
  
  # Attributes
  def from_year
    return nil unless from
    
    from.try(:year).to_s
  end
  
  def from_year=(value)
    return self.from = nil if value.nil?
    
    self.from = Date.new(value.to_i, 1, 1)
  end
  
  def to_year
    return nil unless to

    to.try(:year).to_s
  end
  
  def to_year=(value)
    return self.to = nil if value.nil?
    
    self.to = Date.new(value.to_i, 12, 31)
  end
  
  def period(format = :default)
    return nil unless (from_year or to_year)
    
    return "vor %s" % to_year if format == :default && from_year.nil? && to_year
    
    return from_year if from_year == to_year
    
    [from_year || '', to_year || ''].compact.join(' - ')
  end
  
  def period=(value)
    self.from_year, self.to_year = self.class.from_s(value)
  end
end
