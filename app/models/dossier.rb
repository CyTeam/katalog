# encoding: utf-8

# This class represents a dossier with many containers.
class Dossier < ActiveRecord::Base

  # PaperTrail: change log
  has_paper_trail :ignore => [:created_at, :updated_at, :delta], 
                  :meta   => {:container_ids => Proc.new {|dossier| dossier.container_ids.join(',') },
                              :number_ids    => Proc.new {|dossier| dossier.number_ids.join(',') },
                              :keywords      => Proc.new {|dossier| dossier.temp_keyword_text }}

  # Hooks
  before_save :update_tags

  # Save the keywords for Papertrail
  before_destroy :save_temp_tags
  attr_accessor :temp_keyword_text
  def save_temp_tags
    self.temp_keyword_text = self.keyword_text
  end

  # Simulate default value '' for description as MySQL doesn't support it
  before_save lambda { self.description ||= '' }

  # Validations
  validates :signature, :presence => true, :allow_blank => false
  validates :title, :presence => true, :allow_blank => false
  validates_format_of :first_document_year, :with => /[12][0-9]{3}/, :allow_blank => true

  # Type Scopes
  scope :dossier, where(:type => nil)
  scope :topic, where("type IS NOT NULL")
  scope :group, topic.where("char_length(signature) = 1")
  scope :main, topic.where("char_length(signature) = 2")
  scope :geo, topic.where("char_length(signature) = 4")
  scope :detail, topic.where("char_length(signature) = 8")

  # Scopes
  scope :by_level, lambda {|level| where("char_length(signature) <= ?", self.level_to_prefix_length(level))}
  scope :by_signature, lambda {|value| where("signature LIKE CONCAT(?, '%')", value)}
  scope :by_title, lambda {|value| where("title LIKE CONCAT('%', ?, '%')", value)}
  scope :by_location, lambda {|value| where(:id => Container.where('location_id = ?', Location.find_by_code(value)).map{|c| c.dossier_id}.uniq)} # TODO: check if arel provides nicer code
  scope :by_kind, lambda {|value| where(:id => Container.where('container_type_id = ?', ContainerType.find_by_code(value)).map{|c| c.dossier_id}.uniq)}
  scope :by_character, lambda {|value| where("title LIKE CONCAT(?, '%')", value)}

  # Pagination scope
  scope :characters, select("DISTINCT substring(upper(title), 1, 1) AS letter").having("letter BETWEEN 'A' AND 'Z'")
  def self.character_list
    characters.order('title').map{|t| I18n.transliterate(t.letter) }
  end

  # Ordering
  # BUG: Beware of SQL Injection
  scope :order_by, lambda {|value| order("CONCAT(#{value}, IF(type IS NULL, '.a', '')), title")}

  # Associations
  has_many :numbers, :class_name => 'DossierNumber', :dependent => :destroy, :validate => true, :autosave => true
  accepts_nested_attributes_for :numbers
  has_many :containers, :dependent => :destroy, :validate => true, :autosave => true, :inverse_of => :dossier
  accepts_nested_attributes_for :containers, :allow_destroy => true, :reject_if => :all_blank
    
  # Tags
  acts_as_taggable
  acts_as_taggable_on :keywords

  cattr_reader :level_to_prefix_length
  def self.level_to_prefix_length(level)
    case level.to_s
      when "1"
        1
      when "2"
        2
      when "3"
        4
      when "4"
        8
    end
  end

  # Grand total of documents
  def self.document_count
    includes(:numbers).sum(:amount).to_i
  end

  # Random from all children dossiers
  def random_children(count = 3)
    Dossier.by_signature(self.signature).sample(count)
  end

  # Importer
  def self.import_all(rows)
    new_dossier = true
    title = nil
    dossier = nil
    rows.each do |row|
      transaction do
      begin
        # Skip empty rows
        next if row.select{|column| column.present?}.empty?

        # Only import keywords if row has no reference
        if row[0].blank? && (row[7].present? || row[8].present? || row[9].present?)
          dossier.import_keywords(row)
          dossier.save!
          next
        end

        old_title = title
        title = Dossier.truncate_title(row[1])
        new_dossier = (old_title != title)

        if new_dossier
          dossier = self.create(
            :signature         => row[0],
            :title             => title
          )
          puts dossier unless Rails.env.test?
        end

        dossier.import(row)

        dossier.save!
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end

      puts "  #{dossier.containers.last.period}" unless Rails.env.test?
      end
    end
  end

  # Defines the import filter.
  def self.import_filter(rows)
    signature_filter = /^[ ]*[0-9]{2}\.[0-9]\.[0-9]{3}[ ]*$/

    rows.select{|row| (signature_filter.match(row[0]) && row[3].present?) || (row[0].blank? && (row[7].present? || row[8].present? || row[9].present?))}
  end

  # Prepares the database for a new import.
  # It will delete all entries of the classes:
  #
  # * Container
  # * Dossier
  # * DossierNumber
  # * ActsAsTaggableOn::Tag
  # * ActsAsTaggableOn::Tagging
  # * Version
  def self.prepare_db_for_import
    Container.delete_all
    Dossier.delete_all
    DossierNumber.delete_all

    ActsAsTaggableOn::Tag.delete_all
    ActsAsTaggableOn::Tagging.delete_all

    Version.delete_all
  end

  def self.finish_import
    Topic.alphabetic_sub_topics.each do |topics|
      topics.destroy_all
    end
  end

  # Imports the data from a csv file.
  def self.import_from_csv(path)
    # Disable PaperTrail for speedup
    paper_trail_enabled = PaperTrail.enabled?
    PaperTrail.enabled = false

    # Load file at path using ; as delimiter
    rows = FasterCSV.read(path, :col_sep => ';')

    # Drop all entries
    self.prepare_db_for_import

    # Select rows containing topics
    topic_rows = rows.select{|row| Topic.import_filter.match(row[0]) && row[3].blank? && row[1].present?}
    topic_rows.map{|row| Topic.import(row).save!}

    import_all(import_filter(rows))

    # Drop alphabetic subtitles
    self.finish_import
    
    # Reset PaperTrail state
    PaperTrail.enabled = paper_trail_enabled
  end

  def self.filter_tags(values)
    boring = ["in", "und", "für"]
    values -= boring

    values.reject!{|value| value.match /^[0-9.']*$/}
    values.reject!{|value| value.match /^(Jan|Feb|März|Apr|Mai|Juni|Juli|Aug|Sep|Sept|Okt|Nov|Dez)$/}

    values
  end

  def self.split_words(value)
    value.split(/[ %.();,:-]/).uniq.select{|t| t.present?}
  end

  def self.extract_tags(values)
    values = values.join(',') if values.is_a? Array
    filter_tags(split_words(values)).compact
  end

  def self.extract_keywords(values)
    value_list = values.join('. ')

    # Build quotation substitutes
    abbrs = ["HK.H.", "Evang.", "jun.", "P.G.Z.", "Inh.", " Ltd.", "progr.", "z.", "...", "Änd.", "Ex.", "P.M.", "P.S.", "C.E.D.R.I.", "betr.", "Kt.", "Präs.", "St.", "EXPO.02", "Abst.", "Lib.", "gest.", "ex.", "Hrsg.", "S.o.S", "S.O.S.", "S.o.S.", "s.a.", "SA.", "S.A.", "A.O.M.", "Dr.", "jur.", "etc.", "ca.", "schweiz.", "Dir.", "Hist.", "Chr.", "ev.-ref.", "Kand.", "ev.", "ref.", "ehem.", "str."]
    quoted_abbrs = {}
    for abbr in abbrs
      quoted_abbrs[abbr] = abbr.gsub('.', '|')
    end

    # Quote abbreviations
    quoted_abbrs.each{|abbr, quoted_abbr| value_list.gsub!(abbr, quoted_abbr)}

    # Quote dates
    # TODO: Check if this could be done much simpler using gsub and block
    list = value_list
    quoted = ""
    while match = /#{date_range}/.match(list)
      quoted += match.pre_match

      date = list.slice(match.begin(0)..match.end(0)-1)
      quoted += date.gsub('.', '|')

      list = match.post_match
    end
    value_list = quoted + list

    # Quote initials
    value_list.gsub!(/((^|[ ])[A-Z])\./, '\1|')

    # Quote bracketed terms
    # Need a clone or slice! will do some harm
#    value_term = value_list.clone
#    value_brackets = value_term.slice!(/^[^(]*/)
#    while bracket_term = value_term.slice!(/\([^(]*\)/)
#      value_brackets << bracket_term.gsub('.', '|');
#    end
#    value_brackets << value_term
#    value_list = value_brackets

    # Split and unquote
    keywords = value_list.split('.')
    keywords.map!{|keyword| keyword.gsub('|', '.')}

    # Cleanup
    keywords.compact!
    keywords.map!{|value| value.strip.presence}

    return keywords
  end

  def self.date_range
    month_abbrs = '(Jan\.|Feb\.|März|Apr\.|Mai|Juni|Juli|Aug\.|Sep\.|Sept\.|Okt\.|Nov\.|Dez\.)'
    month_ordinals = '([1-9]\.|1[0-2]\.)'

    year = '[0-9]{4}'
    date = "([0-9]{1,2}\\.)?[ ]*((#{month_abbrs}|#{month_ordinals}|#{year})[ ]*){1,2}"
    date_range = "#{date}([ ]*-[ ]*(#{date})?)?"

    return "[ ]*#{date_range}[ ]*"
  end

  # Report helpers
  def self.years(interval = 1, custom = nil)
    interval = 1 if interval.nil?

    years = nil

    case custom
      when 'main'
        years = DossierNumber.main_report_periods
      else
        years = DossierNumber.default_periods(Date.today.year, false)
    end

    prepared_years = years.dup
    if !(interval.to_s.include?(",")) && interval.to_i > 1
      prepared_years.reject! do |item|
        years.index(item).modulo(interval.to_i) != 0
      end

      prepared_years << {:from => prepared_years.last[:from] + 1, :to => years.last[:to]}

      previous_item = nil
      prepared_years.each do |item|
        item[:from] = previous_item[:to] + 1 if previous_item
        previous_item = item
      end
    elsif interval.to_s.include?(",")
      prepared_years = Array.new
      year_intervals = interval.to_s.split(",")

      year_intervals.each do |year_interval|
        if year_interval.include?("-")
          interval_years = year_interval.split("-")
          cleaned_interval_years = interval_years.reject {|item| item == ""}

          if cleaned_interval_years.count > 1
            from_date_time = concat_year(cleaned_interval_years.first)
            to_date_time = concat_year(cleaned_interval_years.last)
            prepared_years << {:from => DateTime.new(from_date_time), :to => DateTime.new(to_date_time)}
          else
            date_time = concat_year(cleaned_interval_years.first)
            prepared_years << {:from => nil, :to => DateTime.new(date_time)}
          end
        elsif year_interval.include?("*")
          prepared_years << {:from => prepared_years.last[:to], :to => DateTime.current}
        else
          date_time = concat_year(year_interval)
          prepared_years << {:from => DateTime.new(date_time), :to => DateTime.new(date_time, 12, 31)}
        end
      end
    end

    prepared_years.inject([]) do |result, year|
      if year.eql?years.first
        result << 'vor 1990'
      elsif prepared_years.first.eql?year and (year_intervals && year_intervals.first.starts_with?("-"))
        result << "vor #{year[:to].strftime("%Y")}"
      elsif year[:from] && year[:from].strftime("%Y").eql?(year[:to].strftime("%Y"))
        result << "#{year[:from].strftime("%Y")}"
      else
        result << "#{year[:from] ? year[:from].strftime("%Y") : ''} - #{year[:to].strftime("%Y")}"
      end
    end
  end

  def self.concat_year(year)
    prefix = "20"
    prefix = "19" if year.starts_with?"9"
    prefix = "19" if year.starts_with?"8"

    (prefix + year).to_i
  end

  def to_s
    "#{signature}: #{title}"
  end

  def waiting_list
    containers.where(:location_id => Location.find_by_code('RI')).map {|container| container.period unless container.period.blank? }
  end

  # Returns if the current dossier should be preorder.
  def preorder
    containers.each do |c|
      return true if c.preorder
    end
  end

  # Returns the relations as array.
  def relations
    return [] if related_to.blank?

    related_to.split(';').map{|relation| relation.strip.presence}.compact
  end

  # Sets the relations from an array.
  def relations=(value)
    self.related_to = value.join('; ')
  end

  # Returns a relations list with the relations separated throw new lines.
  def relation_list
    relations.join("\n")
  end

  # Sets the relations from a value which is separated throw new lines.
  def relation_list=(value)
    self.relations = value.split("\n")
  end

  # Returns the titles of the relations.
  def relation_titles
    stripped_relations = relations.map{|relation| relation.strip.presence}.compact
    
    titles = stripped_relations.map{|relation| relation.gsub(/^[0-9.]{1,8}:[ ]*/, '')}

    titles
  end

  # Sets the location.
  def location=(value)
    if value.is_a?(String)
      write_attribute(:location, Location.find_by_code(value))
    else
      write_attribute(:location, value)
    end
  end

  # Sets the signature.
  def signature=(value)
    value.strip!
    write_attribute(:signature, value)
    
    group = value[0,1]
    topic, geo, dossier = value.split('.')
  end

  # Association attributes
  def dossier_number_list
    numbers.map{|number| number.to_s(:short)}.join("\n")
  end

  # Saves the dossier numbers from a list.
  def dossier_number_list=(value)
    dossier_number_strings = value.split("\n")
    
    # Remember number objects
    old_numbers = numbers.clone
    new_numbers = []

    dossier_number_strings.map{|number_string|
      # Parse string
      from, to, amount = DossierNumber.from_s(number_string)
      # Remember updated/created number
      new_numbers << update_or_create_number(amount, {:from => from, :to => to}, false) if (amount and amount > 0)
    }

    removed_numbers = old_numbers - new_numbers
    # Remove now unused number from the association
    self.numbers = self.numbers - removed_numbers

    # Destroy the number object
    removed_numbers.map{|number| number.destroy}
  end

  # Returns the dossier number of a year.
  def dossier_number_from_year(to = Time.now.year)
    numbers.where(:to => "#{to}-12-31").first
  end

  # Returns the keywords as text separated throw new lines.
  def keyword_text
    keyword_list.sort.join("\n")
  end
  alias keyword_text= keyword_list=

  # Calculations
  def availability
    availabilities = containers.collect{|c| c.location.availability}
    availabilities << 'intern' if self.internal?

    availabilities.uniq
  end

  # Returns the locations unified.
  def locations
    containers.collect{|c| c.location}.uniq
  end

  # Returns the container types unified.
  def container_types
    containers.collect{|c| c.container_type}.uniq
  end

  # Returns the document count of a specified period.
  def document_count(period = nil)
    document_counts = period ? numbers.between(period) : numbers

    document_counts.sum(:amount).to_i
  end

  has_one :direct_parent, :class_name => 'Topic', :foreign_key => 'signature', :primary_key => 'signature'

  # Returns the last entry of the parents.
  def parent
    parents.last
  end

  # Returns all parent dossiers.
  def parents
    Dossier.where("NOT(type = 'Dossier') AND ? LIKE CONCAT(signature, '%')", signature).order(:signature)
  end

  # Cache invalidating
  after_save :expire_parents
  def expire_parents
    parents.map{|parent| parent.touch}
  end

  # Returns the year of the first document.
  def first_document_year
    first_document_on.try(:year)
  end

  # Sets the year of the first document.
  def first_document_year=(value)
    if value.blank?
      date = nil
    else
      date = Date.new(value.to_i, 1, 1)
    end
    
    self.first_document_on = date
  end

  # Returns a list with how much document count a year has
  def years_counts(interval = 1, custom = nil)
    periods = Dossier.years(interval, custom)

    periods.inject([]) do |result, period|
      result << {:period => period, :count => document_count(period)}
    end
  end

  def self.truncate_title(value)
    value.gsub(/ #{date_range}$/, '')
  end

  # Updates or creates dossier numbers.
  def update_or_create_number(amount, range, accumulate = true)
    # We can't use .count or .where until the Dossier is guaranteed to be saved
    number = numbers.select{|n|
      from = n.from.nil? ? '' : n.from.to_s(:db)
      to   = n.to.nil? ? '' : n.to.to_s(:db)
       
      if range[:from]
        range_from = range[:from].is_a?(String) ? range[:from] : range[:from].to_s(:db)
      else
        range_from = ''
      end
      if range[:to]
        range_to = range[:to].is_a?(String) ? range[:to] : range[:to].to_s(:db)
      else
        range_to = ''
      end

      from == range_from && to == range_to
    }.first

    if number
      amount ||= 0
      number.amount ||= 0
      amount += number.amount if accumulate
    else
      number = numbers.build(range)
    end

    number.amount = amount
    
    number
  end

  # Prepares a new dossier number.
  def prepare_numbers(year = Date.today.year)
    update_or_create_number(0, :from => Date.new(year, 1, 1), :to => Date.new(year, 12, 31))
  end

  # Builds the default dossier numbers.
  def build_default_numbers
    periods = DossierNumber.default_periods
    
    periods.each {|period| numbers.build(period)}
  end

  def import_numbers(row)
    # < 1990, 1990-1993, 1994 - 2010
    periods = DossierNumber.default_periods(2010)
    first_column = 10
    for i in 0..18
      amount = row[first_column + i]
      amount = amount.nil? ? nil : amount.delete("',").to_i

      update_or_create_number(amount, periods[i]) unless amount == 0
    end
  end

  # Updates the dossier tags.
  def update_tags
    # Take all (multi-word) keywords and the title as input
    tag_string = self.keyword_list.join(',') + "," + self.title

    # Extract single word tags
    self.tag_list = self.class.extract_tags(tag_string)
  end

  # Imports the key words.
  def import_keywords(row)
    keys = self.class.extract_keywords(row[7..9])
    self.keyword_list.add(keys)
  end

  # Imports the dossier.
  def import(row)
    # containers
    containers << Container.import(row, self)
    
    self.related_to = row[6] || ''

    # tags and keywords
    import_keywords(row)
    update_tags
    import_numbers(row)
  end

  # Creates the link to winmedio.net
  def books_link
    if alphabetic?
      "http://www.winmedio.net/doku-zug/default.aspx?q=#{alphabetic_book_link}"
    else
      "http://www.winmedio.net/doku-zug/default.aspx?q=erw:0%7C34%7C#{signature}"
    end
  end

  def alphabetic?
    Topic.alphabetic?(signature)
  end

  def tooltip
    html_output = "<h1>#{I18n::translate('katalog.dossier_count_per_year')}</h1>"  unless self.numbers.present.empty?
    self.numbers.present.each do |number|
      html_output += "<p style='#{cycle('odd', 'even')}'><label>#{number.period}:</label> #{number.amount}</p>"
    end

    html_output
  end

  # Excel Export
  include Dossiers::ExportToXls

  # Sphinx Freetext Search
  include Dossiers::Sphinx

  # Paper Trail
  include Dossiers::PaperTrail

  # Text helper
  include ActionView::Helpers::TextHelper

  private

  def alphabetic_book_link
    apply_semantic_rules(title)
  end

  def remove_unpleasant_chars(string)
    string = remove_bracket(string)
    string = remove_short_cuts(string)
    string = remove_special_chars(string)

    replace_comma(string)
  end

  def remove_special_chars(string)
    (string.gsub(/[^[[:alphanum]] \-\.]/, '')).gsub(/\s/, '')
  end

  def remove_short_cuts(string)
    string.gsub(/(AG|SA)/, "")
  end

  def remove_bracket(string)
    string.gsub(/\(.*\)/, "")
  end

  def replace_comma(string)
    string.gsub(',', ' ')
  end

  def apply_semantic_rules(query)
    query = remove_unpleasant_chars(query)
    return query unless query.include?('.')

    'erw:0%7C1%7C' + query.gsub(/(\s*\.\s*)/, "%241%7C1%7C")
  end
end
