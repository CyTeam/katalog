class DossierNumber < ActiveRecord::Base
  # Associations
  belongs_to :dossier

  # Scopes
  scope :present, where("amount > 0")
  
  def to_s
    "#{period}: #{amount}"
  end
  
  # Attributes
  def from_year
    return nil unless from
    
    from.try(:year).to_s
  end
  
  def from_year=(value)
    self.from = Date.new(value.to_i, 1, 1)
  end
  
  def to_year
    return nil unless to

    to.try(:year).to_s
  end
  
  def to_year=(value)
    self.to = Date.new(value.to_i, 12, 31)
  end
  
  def period
    return nil unless (from_year or to_year)
    
    return from_year if from_year == to_year
    
    [from_year, to_year].compact.join(' - ')
  end
  
  def period=(value)
    # Convert integers to string
    value = value.to_s
    
    if value =~ /-/
      self.from_year, self.to_year = value.split('-').map{|year| year.strip }
    else
      self.from_year = self.to_year = value.strip
    end
  end
end
