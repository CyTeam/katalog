class DossierNumber < ActiveRecord::Base
  # Associations
  belongs_to :dossier

  # Validation
  validate :presence_of_from_or_to
  private
    def presence_of_from_or_to
      errors.add(:base, "From, To or both need to be present") unless (from || to)
    end
  public
  
  # Scopes
  scope :present, where("amount > 0")
  scope :by_period, lambda {|value|
    from, to = from_s(value)
    
    where(:from => from, :to => to)
  }
  
  def to_s(format = :default)
    "#{period(format)}: #{amount}"
  end
  
  def self.from_s(value)
    # Convert integers to string
    value = value.to_s
    
    period, amount_s = value.split(':')
    if period =~ /-/
      from, to = period.split('-').map{|year| year.present? ? year.to_i : nil}
    else
      from = to = (period.present? ? value.to_i : nil)
    end

    # from and to should be begin/end of year if not nil
    from = Date.new(from, 1, 1) if from
    to = Date.new(to, 12, 31) if to
    return [from, to, amount_s.to_i]
  end
  
  def self.update_or_create_amount_by_period(period, amount)
    record = find_or_build(period, scope)
    
    record.amount = amount
    record.save
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
    
    return "vor %i" % (to_year.to_i + 1) if format == :default && from_year.nil? && to_year
    
    return from_year if from_year == to_year
    
    [from_year || '', to_year || ''].compact.join(' - ')
  end
  
  def period=(value)
    self.from, self.to = self.class.from_s(value)
  end

  # "All" Periods
  # 
  # < 1990, 1990-1993, 1994 - :up_to
  def self.default_periods(up_to = Date.today.year)
    periods = []
    # before 1990
    periods << {:from => nil, :to => Date.new(1989, 12, 31)}
    # 1990-1993
    periods << {:from => Date.new(1990, 1, 1), :to => Date.new(1993, 12, 31)}
    
    # 1994-
    for year in 1994..up_to
      periods << {:from => Date.new(year, 1, 1), :to => Date.new(year, 12, 31)}
    end
    
    periods
  end
end
