# This class holds the information form date to to date how much dossiers exists.
class DossierNumber < ActiveRecord::Base

  # PaperTrails: change log
  has_paper_trail :ignore => [:created_at, :updated_at]

  # Associations
  belongs_to :dossier

  # Validation
  validate :presence_of_from_or_to

  # Scopes
  scope :present, where("amount > 0")
  scope :by_period, lambda {|value|
    from, to = from_s(value)
    
    where(:from => from, :to => to)
  }
  scope :between, lambda {|value|
    from, to = from_s(value)
    
    where("(`from` IS NULL AND `to` >= :to) OR (`from` >= :from AND `to` <= :to) OR (`from` <= :from AND `to` IS NULL)", {:from => from, :to => to})
  }

  # Returns period for a string.
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

  # Returns the default periods.
  #
  # < 1990, 1990-1993, 1994 - :up_to
  def self.default_periods(up_to = Date.today.year, special = true)
    periods = []
    # before 1990
    periods << {:from => nil, :to => Date.new(1989, 12, 31)}
    # 1990-1993
    periods << {:from => Date.new(1990, 1, 1), :to => Date.new(1993, 12, 31)} if special
    start_year = special ? 1994 : 1990
    # 1994-
    for year in start_year..up_to
      periods << {:from => Date.new(year, 1, 1), :to => Date.new(year, 12, 31)}
    end

    periods
  end

  # Returns the default period as string.
  def self.default_periods_as_s
    self.default_periods.inject([]) do |out, period|
      out << self.period(period[:from], period[:to])
    end
  end

  # Returns the main report periods.
  def self.main_report_periods
    periods = []
    # before 1990
    periods << {:from => nil, :to => Date.new(1989, 12, 31)}
    # 1990-2001
    periods << {:from => Date.new(1990, 1, 1), :to => Date.new(2000, 12, 31)}
    # 2001-2005
    periods << {:from => Date.new(2001, 1, 1), :to => Date.new(2005, 12, 31)}
    # 2006 -
    to_year = Date.today.year.to_i
    from_year = 2006
    for year in from_year..to_year
      periods << {:from => Date.new(year, 1, 1), :to => Date.new(year, 12, 31)}
    end

    periods
  end

  # Creates a period array.
  def self.period(from_year, to_year, format = :default)
    return nil unless (from_year or to_year)

    return "vor %i" % (to_year.try(:year).to_i + 1) if format == :default && from_year.nil? && to_year
    
    return from_year.try(:year) if from_year.try(:year) == to_year.try(:year)

    [from_year.try(:year) || '', to_year.try(:year) || ''].compact.join(' - ')
  end

  # Returns a period formated as string.
  def self.as_string(from, to, amount, format = :default)
    "#{self.period(from, to, format)}: #{amount}"
  end
  
  def to_s(format = :default)
    "#{period(format)}: #{amount}"
  end

  # Returns from which year the dossier number is.
  def from_year
    return nil unless from
    
    from.try(:year).to_s
  end

  # Sets the from year of the dossier number.
  def from_year=(value)
    return self.from = nil if value.nil?
    
    self.from = Date.new(value.to_i, 1, 1)
  end

  # Returns to which year the dossier number is.
  def to_year
    return nil unless to

    to.try(:year).to_s
  end

  # Sets the to year of the dossier number.
  def to_year=(value)
    return self.to = nil if value.nil?
    
    self.to = Date.new(value.to_i, 12, 31)
  end

  # Returns the period of the dossier number.
  def period(format = :default)
    return nil unless (from_year or to_year)
    
    return "vor %i" % (to_year.to_i + 1) if format == :default && from_year.nil? && to_year

    return "< %i" % (to_year.to_i + 1) if format == :short && from_year.nil? && to_year

    return from_year if from_year == to_year
    
    [from_year || '', to_year || ''].compact.join(' - ')
  end

  # Sets the period of the dossier number.
  def period=(value)
    self.from, self.to = self.class.from_s(value)
  end

  private # :nodoc

  def presence_of_from_or_to
    errors.add(:base, "From, To or both need to be present") unless (from || to)
  end
end
