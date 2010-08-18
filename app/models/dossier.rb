class Dossier < ActiveRecord::Base
  # Validations
  validates_presence_of :signature, :title
  
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

  # Ordering
  # BUG: Beware of SQL Injection
  scope :order_by, lambda {|value| order("CONCAT(#{value}, IF(type IS NULL, '.a', '')), title")}
  
  # Associations
  has_many :numbers, :class_name => 'DossierNumber', :dependent => :destroy
  accepts_nested_attributes_for :numbers
  has_many :containers, :dependent => :destroy
    
  # Tags
  acts_as_taggable
  acts_as_taggable_on :keywords
  
  # Search
  define_index do
    # fields
    indexes title, :sortable => true
    indexes signature, :sortable => true
    indexes keywords.name, :as => :keywords, :sortable => true
    
    set_property :field_weights => {
      :title    => 10,
      :keywords => 2
    }
      
    # attributes
    has created_at, updated_at
  end

#  sphinx_scope(:by_text) { |value| {:conditions => value} }
  def self.by_text(value, options = {})
    params = {:match_mode => :extended, :star => true}
    params.merge!(options)
    
    query = build_query(value)
    search(query, params)
  end

  # Helpers
  def to_s
    "#{signature}: #{title}"
  end
  
  def self.split_search_words(value)
    sentences = []

    # Need a clone or slice! will do some harm
    query = value.clone
    while sentence = query.slice!(/\".[^\"]*\"/)
      sentences << sentence.delete('"');
    end

    strings = value.split(/[ %();,:-]/).uniq.select{|t| t.present?}
    words = []
    signatures = []
    for string in strings
      if /^[0-9.]{1,8}$/.match(string)
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
      quoted_signatures = signatures.map{|signature| '"' + signature + '"'}
      signature_query= "@signature (#{quoted_signatures.join('|')})"
    end
    
    if sentences.present?
      quoted_sentences = sentences.map{|sentence| '"' + sentence + '"'}
      sentence_query= "@* (#{quoted_sentences.join('|')})"
    end

    word_query = "@* #{words.join(' ')}" if words.present?
    
    query = [signature_query, sentence_query, word_query].join(' ')
    return query
  end
  
  def relation_titles
    stripped_relations = related_to.split(';').map{|relation| relation.strip.presence}.compact
    
    titles = stripped_relations.map{|relation| relation.gsub(/^[0-9.]{1,8}:[ ]*/, '')}

    return titles
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
  
  # Calculations
  def first_document_on
    containers.minimum(:first_document_on)
  end
  
  def locations
    containers.collect{|c| c.location}.uniq
  end
  
  def container_types
    containers.collect{|c| c.container_type}.uniq
  end
  
  def document_count
    numbers.sum(:amount)
  end
  
  def find_parent
    TopicDossier.where(:signature => signature).first
  end
  
  def parent_tree
    return [] unless parent = find_parent
    return parent.parent_tree << parent
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
  
  def self.truncate_title(value)
    value.gsub(/ #{date_range}$/, '')
  end
  
  def self.import_filter
    /^[0-9]{2}\.[0-9]\.[0-9]{3}$/
  end
  
  def import_numbers(row)
    # before 1990
    numbers.create(
      :to     => '1989-12-31',
      :amount => row[16].nil? ? nil : row[16].delete("',").to_i
    )
    # 1990-1993
    numbers.create(
      :from   => '1990-01-01',
      :to     => '1993-12-31',
      :amount => row[17].nil? ? nil : row[17].delete("',").to_i
    )
    # 1994-
    year = 1994
    for amount in row[18..36]
      numbers.create(
        :from   => Date.new(year, 1, 1),
        :to     => Date.new(year, 12, 31),
        :amount => amount.nil? ? nil : amount.delete("',").to_i
      )
      year += 1
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
#        puts e.backtrace
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
    topic_group_rows = rows.select{|row| TopicGroup.import_filter.match(row[0])}
    topic_group_rows.map{|row| TopicGroup.import(row).save!}
    
    topic_rows = rows.select{|row| Topic.import_filter.match(row[0])}
    topic_rows.map{|row| Topic.import(row).save!}

    topic_rows = rows.select{|row| TopicGeo.import_filter.match(row[0])}
    topic_rows.map{|row| TopicGeo.import(row).save!}

    topic_rows = rows.select{|row| TopicDossier.import_filter.match(row[0]) && row[9].blank?}
    topic_rows.map{|row| TopicDossier.import(row).save!}

    import_all(import_filter(rows))
  end
end
