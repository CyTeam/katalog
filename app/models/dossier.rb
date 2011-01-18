class Dossier < ActiveRecord::Base
  # Validations
  validates_presence_of :signature, :title
  
  # Type Scopes
  scope :dossier, where(:type => nil)
  scope :topic, where("type IS NOT NULL")
  scope :group, topic.where("char_length(signature) = 1")
  scope :main, topic.where("char_length(signature) = 2")
  scope :geo, topic.where("char_length(signature) = 4")
  scope :detail, topic.where("char_length(signature) = 8")

  # Scopes
  scope :by_text2, lambda {|value|
    signatures, words = split_search_words(value)

    signature_condition = (["(signature LIKE CONCAT(?, '%'))"] * signatures.count).join(' OR ')
    word_condition = (["(id IN (SELECT taggable_id FROM tags INNER JOIN taggings ON taggings.tag_id = tags.id WHERE name LIKE CONCAT('%', ?, '%')))"] * words.count).join(' AND ')

    condition = [signature_condition.presence, word_condition.presence].compact.join(' AND ')
    params = signatures + words
    
    Dossier.where(condition, *params)
  }
  scope :by_signature, lambda {|value| where("signature LIKE CONCAT(?, '%')", value)}
  scope :by_title, lambda {|value| where("title LIKE CONCAT('%', ?, '%')", value)}
  # TODO: check if arel provides nicer code:
  scope :by_location, lambda {|value| where(:id => Container.where('location_id = ?', Location.find_by_code(value)).map{|c| c.dossier_id}.uniq)}
  scope :by_kind, lambda {|value| where(:id => Container.where('container_type_id = ?', ContainerType.find_by_code(value)).map{|c| c.dossier_id}.uniq)}
  scope :by_character, lambda {|value| where("title LIKE CONCAT(?, '%')", value)}
  
  # Pagination
  scope :characters, select("DISTINCT substring(upper(title), 1, 1) AS letter").having("letter BETWEEN 'A' AND 'Z'")
  def self.character_list
    characters.order('title').map{|t| t.letter}
  end

  # Ordering
  # BUG: Beware of SQL Injection
  scope :order_by, lambda {|value| order("CONCAT(#{value}, IF(type IS NULL, '.a', '')), title")}
  
  # Associations
  has_many :numbers, :class_name => 'DossierNumber', :dependent => :destroy, :validate => true, :autosave => true
  accepts_nested_attributes_for :numbers
  has_many :containers, :dependent => :destroy
  accepts_nested_attributes_for :containers, :allow_destroy => true, :reject_if => :all_blank
    
  # Tags
  acts_as_taggable
  acts_as_taggable_on :keywords
  
  # Search
  define_index do
    set_property :group_concat_max_len => 1048576

    # fields
    indexes title
    indexes signature
    indexes keywords.name, :as => :keywords

    has sort_key
    has type
    
    set_property :field_weights => {
      :title    => 500,
      :keywords => 2
    }
    set_property :delta => true unless Rails.env.import? # Disable delta update in import as it slows down too much
      
    # attributes
    has created_at, updated_at
  end

#  sphinx_scope(:by_text) { |value| {:conditions => value} }
  def self.by_text(value, options = {})
    params = {:match_mode => :extended, :rank_mode => :match_any, :with => {:type => 'Dossier'}, :order => :sort_key, :sort_mode => :desc}
    params.merge!(options)
    
    query = build_query(value)
    search(query, params)
  end

  # Helpers
  def to_s
    "#{signature}: #{title}"
  end
  
  def self.split_search_words(query)
    sentences = []

    # Need a clone or slice! will do some harm
    value = query.clone
    while sentence = value.slice!(/\".[^\"]*\"/)
      sentences << sentence.delete('"');
    end

    strings = value.split(/[ %();,:-]/).uniq.select{|t| t.present?}
    words = []
    signatures = []
    for string in strings
      if /^[0-9]*\.$/.match(string)
        # is an ordinal
        words << string
      elsif /^[0-9]{2}(\.[0-9])?$/.match(string)
        # signature is as ordinal by index
        signatures << string + "."
      elsif /^[0-9.]{1,8}$/.match(string)
        signatures << string
      else
        words << string.split('.')
      end
    end
    
    return signatures, words.flatten, sentences
  end
  
  def self.build_query(value)
    signatures, words, sentences = split_search_words(value)

    if signatures.present?
      quoted_signatures = signatures.map{|signature| '"' + signature + '*"'}
      signature_query = "@signature (#{quoted_signatures.join('|')})"
    end
    
    if sentences.present?
      quoted_sentences = sentences.map{|sentence| '"' + sentence + '"'}
      sentence_query = "@* (#{quoted_sentences.join('|')})"
    end

    if words.present?
      quoted_words = words.map {|word|
        if word.length < 2
          word
        elsif word.length == 2
          word + "*"
        elsif word.length > 2
          "+\"" + word + "*\"" + " | " + "*" + word + "*"
        end
      }
      word_query = "@* (\"#{words.join(' ')}\" | (#{(quoted_words).join(' ')}))"
    end
    
    query = [signature_query, sentence_query, word_query].join(' ')
    return query
  end
  
  def relations
    return [] if related_to.blank?
    
    related_to.split(';').map{|relation| relation.strip.presence}.compact
  end
  
  def relations=(value)
    self.related_to = value.join('; ')
  end
  
  def relation_list
    relations.join("\n")
  end
  
  def relation_list=(value)
    self.relations = value.split("\n")
  end
  
  def relation_titles
    stripped_relations = relations.map{|relation| relation.strip.presence}.compact
    
    titles = stripped_relations.map{|relation| relation.gsub(/^[0-9.]{1,8}:[ ]*/, '')}

    titles
  end
  
  # Attributes
  def location=(value)
    if value.is_a?(String)
      write_attribute(:location, Location.find_by_code(value))
    else
      write_attribute(:location, value)
    end
  end
  
  def signature=(value)
    value.strip!
    write_attribute(:signature, value)
    
    group = value[0,1]
    topic, geo, dossier = value.split('.')
    new_signature = [topic, dossier, geo].compact.join('.')
    write_attribute(:new_signature, new_signature)
  end
  
  # Association attributes
  def dossier_number_list
    numbers.map{|number| number.to_s(:short)}.join("\n")
  end
  
  def dossier_number_list=(value)
    # Clean list
    numbers.delete_all
    
    # Parse list
    dossier_number_strings = value.split("\n")
    for dossier_number_string in dossier_number_strings
      from, to, amount = DossierNumber.from_s(dossier_number_string)
      numbers.build(:from => from, :to => to, :amount => amount)
    end
  end

  def keyword_text
    keyword_list.sort.join("\n")
  end
  alias keyword_text= keyword_list=

  # Calculations
  def availability
    containers.collect{|c| c.location.availability}.uniq
  end
  
  def locations
    containers.collect{|c| c.location}.uniq
  end

  def locations_shortcut
    locations.collect{|l| l.to_s.scan(/\((\w*)\)/).first }
  end
  
  def container_types
    containers.collect{|c| c.container_type}.uniq
  end

  def container_types_shortcut
    container_types.collect{|l| l.to_s.scan(/\((\w*)\)/).first }
  end
  
  # Grand total of documents
  def self.document_count
    includes(:numbers).sum(:amount).to_i
  end
  
  def document_count(period = nil)
    document_counts = period ? numbers.between(period) : numbers

    document_counts.sum(:amount).to_i
  end
  
  def parent
    parents.last
  end
  
  def parents
    Dossier.where("NOT(type = 'Dossier') AND ? LIKE CONCAT(signature, '%')", signature).order(:signature)
  end
  
  def first_document_year
    first_document_on.try(:year)
  end

  def first_document_year=(value)
    self.first_document_on = Date.new(value.to_i, 1, 1)
  end

  # Importer
  def self.filter_tags(values)
    boring = ["in", "und", "für"]
    values -= boring
    
    values.reject!{|value| value.match /^[0-9.']*$/}
    values.reject!{|value| value.match /^(Jan|Feb|März|Apr|Mai|Juni|Juli|Aug|Sep|Sept|Okt|Nov|Dez)$/}

    return values
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
  def self.years(interval = 1)
    return [] if interval.nil?
    
    years = DossierNumber.default_periods(Date.today.year, false)
    prepared_years = years.dup
    if interval > 1
      prepared_years.reject! do |item|
        years.index(item).modulo(interval) != 0
      end

      prepared_years << {:from => prepared_years.last[:from] + 1, :to => years.last[:to]}

      previous_item = nil
      prepared_years.each do |item|
        item[:from] = previous_item[:to] + 1 if previous_item
        previous_item = item
      end
    end

    prepared_years.inject([]) do |result, year|
      if year.eql?years.first
        result << 'vor 1990'
      else
        result << "#{year[:from] ? year[:from].strftime("%Y") : ''} - #{year[:to].strftime("%Y")}"
      end
    end
  end

  def years_counts(interval = 1)
    periods = Dossier.years(interval)
    periods.inject([]) do |result, period|
      result << {:period => period, :count => document_count(period)}
    end
  end
  
  def self.truncate_title(value)
    value.gsub(/ #{date_range}$/, '')
  end
  
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
  end
  
  def update_or_create_number(amount, range)
    # We can't use .count or .where until the Dossier is guaranteed to be saved
    number = numbers.select{|n| n.from.to_s == range[:from].to_s && n.to.to_s == range[:to].to_s}.first
    if number
      amount ||= 0
      number.amount ||= 0
      amount += number.amount
    else
      number = numbers.build(range)
    end

    number.amount = amount
  end
  
  def prepare_numbers(year = Date.today.year)
    update_or_create_number(0, :from => Date.new(year, 1, 1), :to => Date.new(year, 12, 31))
  end
  
  def build_default_numbers
    periods = DossierNumber.default_periods
    for period in periods
      numbers.build(period)
    end
  end
  
  def import_numbers(row)
    # < 1990, 1990-1993, 1994 - 2010
    periods = DossierNumber.default_periods(2010)
    first_column = 16
    for i in 0..18
      amount = row[first_column + i]
      amount = amount.nil? ? nil : amount.delete("',").to_i

      update_or_create_number(amount, periods[i]) unless amount == 0
    end
  end
  
  before_save :update_tags
  def update_tags
    tag_string = self.keyword_list.join(',') + "," + self.title
    self.tag_list = self.class.extract_tags(tag_string)
  end
  
  def import_keywords(row)
    keys = self.class.extract_keywords(row[13..15])
    self.keyword_list.add(keys)
  end
  
  def import(row)
    # containers
    containers << Container.import(row, self)
    
    self.related_to = row[12]

    # tags and keywords
    import_keywords(row)
    update_tags
    import_numbers(row)
  end
  
  def self.import_all(rows)
    new_dossier = true
    title = nil
    dossier = nil
    for row in rows
      transaction do
      begin
        # Skip empty rows
        next if row.select{|column| column.present?}.empty?
        
        # Only import keywords if row has no reference
        if row[0].blank? && (row[13].present? || row[14].present? || row[15].present?)
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
        end
        
        dossier.import(row)
        
        dossier.save!
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
      puts dossier unless Rails.env.test?
      end
    end
  end
  
  def self.import_filter(rows)
    signature_filter = /^[ ]*[0-9]{2}\.[0-9]\.[0-9]{3}[ ]*$/

    rows.select{|row| (signature_filter.match(row[0]) && row[9].present?) || (row[0].blank? && (row[13].present? || row[14].present? || row[15].present?))}
  end
  
  def self.import_from_csv(path)
    # Load file at path using ; as delimiter
    rows = FasterCSV.read(path, :col_sep => ';')
    
    # Select rows containing topics
    topic_rows = rows.select{|row| Topic.import_filter.match(row[0]) && row[9].blank?}
    topic_rows.map{|row| Topic.import(row).save!}

    import_all(import_filter(rows))
  end
end
