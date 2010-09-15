class DossierNumber < ActiveRecord::Base
  # Associations
  belongs_to :dossier

  # Validation
  validate :presence_of_from_or_to
  private
    def presence_of_from_or_to
      errors.add_to_base("From, To or both need to be present") unless (from || to)
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
      from, to = value.split('-').map{|year| year.present? ? year.to_i : nil}
    else
      from = to = value.to_i
    end

    # from and to should be begin/end of year if not nil
    from &&= Date.new(from, 1, 1)
    to &&= Date.new(to, 12, 31)
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
    
    return "vor %s" % to_year if format == :default && from_year.nil? && to_year
    
    return from_year if from_year == to_year
    
    [from_year || '', to_year || ''].compact.join(' - ')
  end
  
  def period=(value)
    self.from, self.to = self.class.from_s(value)
  end
end
