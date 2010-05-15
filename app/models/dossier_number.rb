class DossierNumber < ActiveRecord::Base
  belongs_to :dossier

  # Attributes
  def from_year
    from.year
  end
  
  def from_year=(value)
    self.from = Date.new(value.to_i, 1, 1)
  end
  
  def to_year
    to.year
  end
  
  def to_year=(value)
    self.to = Date.new(value.to_i, 12, 31)
  end
  
  def period
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
